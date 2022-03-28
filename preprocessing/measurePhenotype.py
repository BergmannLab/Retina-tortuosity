import os, sys
from datetime import datetime
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import seaborn
import csv
from multiprocessing import Pool
from PIL import Image
import PIL
from scipy import stats
import math


# plot_phenotype = False
aria_measurements_dir = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/ARIA_MEASUREMENTS_DIR'  # sys.argv[3]
qcFile = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/noQC.txt'  # sys.argv[1] # qcFile used is noQCi, as we measure for all images
phenotype_dir = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/OUTPUT'  # sys.argv[2]
lwnet_dir = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/LWNET_DIR'  # sys.argv[4]
fuction_to_execute = 'green_segments'  # sys.argv[5]
df_OD = pd.read_csv("/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/OD_position_11_02_2022.csv",
                    sep=',')


def main_bifurcations(imgname: str) -> dict:
    """
    :param imgname:
    :return:
    """
    try:
        imageID = imgname.split(".")[0]

        df_pintar = read_data(imageID)
        # if plot_phenotype:
        #     img = mpimg.imread(imageID + ".png")
        #     plt.imshow(img)
        #     plt.scatter(x=df_pintar['X'], y=df_pintar['Y'], c=df_pintar['type'], cmap="jet", marker="d",
        #                 alpha=0.5, s=0.2)
        #     plt.savefig(phenotype_dir + '/'+imageID + '_bif.jpg')
        #     plt.close()
        aux = df_pintar.groupby('index')
        df_results = pd.concat([aux.head(1), aux.tail(1)]).drop_duplicates().sort_values('index').reset_index(drop=True)
        df_results['type'] = np.sign(df_results['type'])
        df_results.sort_values(by=['X'], inplace=True, ascending=False)

        return {'bifurcations': float(bifurcation_counter(df_results))}

    except Exception as e:
        print(e)
        return {'bifurcations': np.nan}


def main_tva_or_taa(imgname_and_filter: str and int) -> dict:
    """
    :param imgname_and_filter:
    :return:
    """
    try:
        imgname = imgname_and_filter[0]
        filter_type = imgname_and_filter[1]
        imageID = imgname.split(".")[0]
        df_pintar = read_data(imageID, diameter=True)
        df_pintar['type'] = np.sign(df_pintar['type'])
        OD_position = df_OD[df_OD['image'] == imgname]
        OD_position.dropna(subset=['center_x_y'], inplace=True)
        return {
            'mean_angle': compute_mean_angle(df_pintar, OD_position, filter_type) if not OD_position.empty else None
        }
    except Exception as e:
        print(e)
        return {
            'mean_angle': np.nan}


def main_neo_vascularization_od(imgname: str) -> dict:
    """
    :param imgname:
    :return:
    """
    try:
        imageID = imgname.split(".")[0]
        df_pintar = read_data(imageID)
        df_pintar['type'] = np.sign(df_pintar['type'])
        OD_position = df_OD[df_OD['image'] == imgname]
        return compute_neo_vascularization_od(df_pintar, OD_position) if not OD_position.empty else None
    except Exception as e:
        print(e)
        return {
            'pixels_fraction': np.nan,
            'od_green_pixel_fraction': np.nan
        }


def main_num_green_segment_and_pixels(imgname: str) -> dict:
    """_summary_ this only will work if file are sorted correctly.

    Args:
        imgname (str): _description_

    Returns:
        float: _description_
    """
    try:
        imageID = imgname.split(".")[0]
        df_pintar = read_data(imageID)
        df_type_0 = df_pintar[df_pintar["type"] == 0]
        num_green_pixels = df_type_0.shape[0]
        num_green_segments = df_type_0['index'].nunique()
        return {
            'N_green_segments': float(num_green_segments),
            'N_green_pixels': float(num_green_pixels)
        }

    except Exception as e:
        print(e)
        return {'segments': np.nan, 'pixels': np.nan}


def main_aria_phenotypes(imgname):
    """
    :param imgname:
    :return:
    """
    imageID = imgname.split(".")[0]

    lengthQuints = [23.3, 44.3, 77.7, 135.8]

    all_medians = []
    artery_medians = []
    vein_medians = []
    try:  # because for any image passing QC, ARIA might have failed
        # df is segment stat file
        df = pd.read_csv(aria_measurements_dir + imageID + "_all_segmentStats.tsv", delimiter='\t')
        all_medians = df.median(axis=0).values
        artery_medians = df[df['AVScore'] > 0].median(axis=0).values
        vein_medians = df[df['AVScore'] < 0].median(axis=0).values

        # stats based on longest fifth
        try:
            quintStats_all = df[df['arcLength'] > lengthQuints[3]].median(axis=0).values
            quintStats_artery = df[(df['arcLength'] > lengthQuints[3]) & (df['AVScore'] > 0)].median(axis=0).values
            quintStats_vein = df[(df['arcLength'] > lengthQuints[3]) & (df['AVScore'] < 0)].median(axis=0).values

        except Exception as e:
            print(e)
            print("longest 5th failed")
            quintStats_all = [np.nan for i in range(0, 14)]
            quintStats_artery = quintStats_all
            quintStats_vein = quintStats_all

        df_im = pd.read_csv(aria_measurements_dir + imageID + "_all_imageStats.tsv", delimiter='\t')

        return np.concatenate((all_medians, artery_medians, vein_medians, quintStats_all, \
                               quintStats_artery, quintStats_vein, df_im['nVessels'].values), axis=None).tolist()
    except Exception as e:
        print(e)
        print("ARIA didn't have stats for img", imageID)
        return [np.nan for i in range(0,
                                      84)]  # we measured 14 segment-wise stats using ARIA, for AV, and for longest quint -> 14*6+1=85, and nVessels


def main_fractal_dimension(imgname):
    """
    :param imgname:
    :return:
    """
    imageID = imgname.split(".")[0]
    print(imageID)
    try:
        img = Image.open(imageID + "_bin_seg.png")
        img_artery = replaceRGB(img, (255, 0, 0), (0, 0, 0))
        img_vein = replaceRGB(img, (0, 0, 255), (0, 0, 0))
        # img.save('/home/mbeyele5/im1.png')
        # img_artery.save('/home/mbeyele5/im2.png')
        # img_vein.save('/home/mbeyele5/im3.png')
        w, h = img.size

        box_sidelengths = [2, 4, 8, 16, 32, 64, 128, 256, 512]

        N_boxes, N_boxes_artery, N_boxes_vein = [], [], []
        for i in box_sidelengths:
            w_i = round(w / i)
            h_i = round(h / i)
            img_i = img.resize((w_i, h_i), resample=PIL.Image.BILINEAR)
            img_i_artery = img_artery.resize((w_i, h_i), resample=PIL.Image.BILINEAR)
            img_i_vein = img_vein.resize((w_i, h_i), resample=PIL.Image.BILINEAR)
            # plt.figure()
            # plt.imshow(np.asarray(img_i))
            # plt.savefig("/users/mbeyele5/"+imageID+str(i)+".png")

            N_boxes.append(np_nonBlack(np.asarray(img_i)))
            N_boxes_artery.append(np_nonBlack(np.asarray(img_i_artery)))
            N_boxes_vein.append(np_nonBlack(np.asarray(img_i_vein)))

        # print(box_sidelengths,N_boxes)
        # plt.figure()
        # plt.scatter( np.log( [1/i for i in box_sidelengths] ), np.log(N_boxes) )
        # plt.savefig("/users/mbeyele5/"+imageID+"_scatter.png")

        slope, intercept, r_value, p_value, std_err = stats.linregress(np.log([1 / i for i in box_sidelengths]),
                                                                       np.log(N_boxes))
        slope_artery, intercept, r_value, p_value, std_err = stats.linregress(np.log([1 / i for i in box_sidelengths]),
                                                                              np.log(N_boxes_artery))
        slope_vein, intercept, r_value, p_value, std_err = stats.linregress(np.log([1 / i for i in box_sidelengths]),
                                                                            np.log(N_boxes_vein))

        # print(slope, intercept,r_value,p_value,std_err)
        return slope, slope_artery, slope_vein

    except Exception as e:
        print(e)
        print("image", imgname, "does not exist")
        return np.nan, np.nan, np.nan


def get_data_unpivot(path):
    """
    :param path:
    :return:
    """
    # Use .read_fwf since *.tsv have diferent fixed-width formatted lines
    # df = pd.read_fwf(path, sep='\t', header=None)
    # Split by tab and expand columns
    with open(path) as fd:
        rd_2 = csv.reader(fd, delimiter='\t')
        df = pd.DataFrame([row for row in rd_2])
    # get index in order to get the each segment id
    df.reset_index(inplace=True)
    # unpivot dataframe to get all the segments coordinates in one column
    df_unpivot = pd.melt(df, id_vars=['index']).sort_values(by=['index', 'variable'])[['index', 'value']]
    # remove null created by fixed-width
    df_unpivot = df_unpivot[~df_unpivot['value'].isnull()].copy()
    # get another index to get a secod key in order to merge
    df_unpivot.reset_index(inplace=True)
    return df_unpivot


def read_data(imageID, diameter=False):
    """

    :return:
    """
    x = get_data_unpivot(f"{aria_measurements_dir}/{imageID}_all_rawYCoordinates.tsv")
    y = get_data_unpivot(f"{aria_measurements_dir}/{imageID}_all_rawXCoordinates.tsv")
    df_all_seg = pd.read_csv(f"{aria_measurements_dir}/{imageID}_all_segmentStats.tsv", sep='\t')
    df_all_seg.reset_index(inplace=True)
    if diameter:
        diameters = get_data_unpivot(f"{aria_measurements_dir}/{imageID}_all_rawDiameters.tsv")
        df_merge = pd.merge(
            x, y,
            how='outer',
            on=['index', 'level_0']).merge(
            diameters,
            how='outer',
            on=['index', 'level_0']).merge(
            df_all_seg[['index', "AVScore"]],
            how='outer',
            on='index',
            indicator=True).rename(columns={'value_x': 'X', 'value_y': 'Y', 'value': 'Diameter', 'AVScore': 'type'})
        df_merge['X'] = pd.to_numeric(df_merge['X'])
        df_merge['Y'] = pd.to_numeric(df_merge['Y'])
        df_merge['Diameter'] = pd.to_numeric(df_merge['Diameter'])

        return df_merge

    df_merge = pd.merge(
        x, y, how='outer', on=['index', 'level_0']).merge(
        df_all_seg[['index', "AVScore"]],
        how='outer',
        on='index',
        indicator=True).rename(columns={'value_x': 'X', 'value_y': 'Y', 'AVScore': 'type'})

    df_merge['X'] = pd.to_numeric(df_merge['X'])
    df_merge['Y'] = pd.to_numeric(df_merge['Y'])

    return df_merge


def ang(lineA, lineB):
    """
    :param lineA:
    :param lineB:
    :return:
    """
    # Get nicer vector form
    vA = [(lineA[0][0] - lineA[1][0]), (lineA[0][1] - lineA[1][1])]
    vB = [(lineB[0][0] - lineB[1][0]), (lineB[0][1] - lineB[1][1])]
    # Get dot prod
    dot_prod = np.dot(vA, vB)
    # Get magnitudes
    magA = np.dot(vA, vA) ** 0.5
    magB = np.dot(vB, vB) ** 0.5
    # Get angle in radians and then convert to degrees
    angle = math.acos(dot_prod / magB / magA)
    # Basically doing angle <- angle mod 360
    ang_deg = math.degrees(angle) % 360

    return 360 - ang_deg if ang_deg >= 180 else ang_deg


def np_nonBlack(img):
    return img.any(axis=-1).sum()


def replaceRGB(img, old, new):
    """
    :param img:
    :param old:
    :param new:
    :return:
    """
    out = img.copy()
    datas = out.getdata()
    newData = []
    for item in datas:
        if item[0] == old[0] and item[1] == old[1] and item[2] == old[2]:
            newData.append((new[0], new[1], new[2]))
        else:
            newData.append(item)
    out.putdata(newData)
    return out


def bifurcation_counter(df_results):
    """
    :param df_results:
    :return:
    """
    X_1_aux = X_2_aux = 0.0
    bif_counter = 0
    cte = 3.5
    number_rows = df_results.shape[0]
    x = df_results['X'].values
    y = df_results['Y'].values
    dis_type = df_results['type'].values
    index_v = df_results['index'].values

    for s in range(number_rows):
        for j in range(number_rows - s):
            j = j + s
            # For X and Y: X[s] - cte <= X[j] <= X[s]
            # Both arteries or both veins and != type 0
            if (x[j] >= x[s] - cte) and (x[j] <= x[s] + cte):
                if (y[j] >= y[s] - cte) and (y[j] <= y[s] + cte):
                    if index_v[j] != index_v[s]:
                        if (dis_type[j] == dis_type[s]) and \
                                (dis_type[j] != 0 or dis_type[s] != 0):
                            if (x[j] != X_1_aux and x[s] != X_1_aux and
                                    x[j] != X_2_aux and x[s] != X_2_aux):
                                bif_counter = bif_counter + 1
                                X_1_aux = x[s]
                                X_2_aux = x[j]
                else:
                    continue
    return bif_counter


def circular_df_filter(radio, angle, od_position, df_pintar):
    """
    :param radio:
    :param angle:
    :param od_position:
    :param df_pintar:
    :return:
    """
    df_circle = compute_circular_df(radio, angle, od_position)
    new_df = pd.merge(df_circle, df_pintar, how='inner', left_on=['X', 'Y'], right_on=['X', 'Y'])
    return new_df.drop_duplicates(subset=['index'], keep='last')


def compute_circular_df(radio, angle, od_position):
    """
    :param radio:
    :param angle:
    :param od_position:
    :return:
    """
    x = radio * np.cos(angle) + od_position['x'].iloc[0]
    y = radio * np.sin(angle) + od_position['y'].iloc[0]
    df_circle = pd.DataFrame([])
    df_circle['X'] = x.round(0)
    df_circle['Y'] = y.round(0)
    return df_circle


def compute_potential_vein_arteries(df_veins_arter, od_position):
    """
    :param df_veins_arter:
    :param od_position:
    :return:
    """
    aux = []
    veins_art_x = df_veins_arter['X'].values
    veins_art_y = df_veins_arter['Y'].values
    veins_art_index = df_veins_arter['index'].values
    veins_art_diameter = df_veins_arter['Diameter'].values
    veins_art_type = df_veins_arter['type'].values
    for i in range(df_veins_arter.shape[0] - 1):
        for j in range(df_veins_arter.shape[0] - 2):
            lineA = ((od_position['x'].iloc[0], od_position['y'].iloc[0]), (veins_art_x[i], veins_art_y[i]))
            lineB = ((od_position['x'].iloc[0], od_position['y'].iloc[0]), (veins_art_x[j], veins_art_y[j]))
            if i == j:
                continue
            angulo = ang(lineA, lineB)
            angulo = round(angulo, 0)
            data = {
                'X_1': veins_art_x[i],
                'Y_1': veins_art_y[i],
                'Diameter_1': veins_art_diameter[i],
                'type_1': veins_art_type[i],
                'i_1': veins_art_index[i],
                'X_2': veins_art_x[j],
                'Y_2': veins_art_y[j],
                'Diameter_2': veins_art_diameter[j],
                'type_2': veins_art_type[j],
                'i_2': veins_art_index[j],
                'angle': angulo
            }
            aux.append(data)
    return pd.DataFrame(aux)


def get_main_angle_row(df_potential_points):
    """
    :param df_potential_points:
    :return:
    """
    d = {'X_1': 0, 'Y_1': 0, 'Diameter_1': 0, 'type_1': 0, 'i_1': 0, 'X_2': 0, 'Y_2': 0, 'Diameter_2': 0, 'type_2': 0,
         'i_2': 0, 'angle': 0}
    main_angle = pd.Series(data=d,
                           index=['X_1', 'Y_1', 'Diameter_1', 'type_1', 'i_1', 'X_2', 'Y_2', 'Diameter_2', 'type_2',
                                  'i_2', 'angle'])
    if not df_potential_points.empty:
        df_angles_1 = df_potential_points[(df_potential_points["angle"] >= 90) & (df_potential_points["angle"] <= 230)]
        df_angles_1 = df_angles_1.sort_values(['Diameter_1', 'Diameter_2'], ascending=[False, False])
        if not df_angles_1.empty:
            main_angle = df_angles_1.iloc[0]
    return main_angle


def get_data_angle(df_potential_points):
    """
    :param df_potential_points:
    :return:
    """
    main_angle_row = get_main_angle_row(df_potential_points)
    return {
        'X_1': main_angle_row['X_1'],
        'Y_1': main_angle_row['Y_1'],
        'Diameter_1': main_angle_row['Diameter_1'],
        'X_2': main_angle_row['X_2'],
        'Y_2': main_angle_row['Y_2'],
        'Diameter_2': main_angle_row['Diameter_2'],
        'angle': main_angle_row['angle']
    }


def get_radious_votes(df_pintar, OD_position, filter_type):
    """
    :param df_pintar:
    :param OD_position:
    :param filter_type:
    :return:
    """
    angle = np.arange(0, 360, 0.01)
    df_pintar['X'] = df_pintar['X'].round(0)
    df_pintar['Y'] = df_pintar['Y'].round(0)
    auxiliar_angle = []
    radius = [240, 250, 260, 270, 280, 290]
    for p in radius:
        new_df_2 = circular_df_filter(p, angle, OD_position, df_pintar)
        df_veins_arter = new_df_2[new_df_2["type"] == filter_type]
        df_veins_arter.sort_values(by=['Diameter'], ascending=False, inplace=True)
        df_potential_points = compute_potential_vein_arteries(df_veins_arter, OD_position)
        auxiliar_angle.append(get_data_angle(df_potential_points))
    return pd.DataFrame(auxiliar_angle)


def get_angle_mode(df_final_vote):
    """
    :param df_final_vote:
    :return:
    """
    for i in range(len(df_final_vote) - 1):
        for j in range(len(df_final_vote)):
            if (df_final_vote['angle'].loc[i + 1] >= df_final_vote['angle'].loc[j] - 15) and (
                    df_final_vote['angle'].loc[i + 1] <= df_final_vote['angle'].loc[j] + 2):
                df_final_vote['vote_angle'].loc[i + 1] = j
                break
    return df_final_vote[df_final_vote['vote_angle'] == df_final_vote.mode()['vote_angle'][0]].copy()


def compute_mean_angle_with_mode(df_final_vote):
    """
    :param df_final_vote:
    :return:
    """
    df_final = get_angle_mode(df_final_vote)
    return df_final['angle'].mean() if df_final.shape[0] >= 3 and not df_final['angle'].mean() == 0.0 else None


def compute_mean_angle(df_pintar, OD_position, filter_type=-1):
    """
    :param df_pintar:
    :param OD_position:
    :param filter_type:
    :return:
    """
    df_final_vote = get_radious_votes(df_pintar, OD_position, filter_type)
    df_final_vote = df_final_vote.reset_index().rename(columns={'index': 'vote_angle'}).copy()
    return compute_mean_angle_with_mode(df_final_vote)


def compute_vessel_radius_pixels(df_pintar, radius, od_position):
    """
    :param df_pintar:
    :param radius:
    :param od_position:
    :return:
    """
    df_pintar['DeltaX'] = df_pintar['X'] - od_position['x'].iloc[0]
    df_pintar['DeltaY'] = df_pintar['Y'] - od_position['y'].iloc[0]
    df_pintar['r2_value'] = df_pintar['DeltaX'] * df_pintar['DeltaX'] + df_pintar['DeltaY'] * df_pintar['DeltaY']
    df_pintar['r_value'] = (df_pintar['r2_value']) ** (1 / 2)

    return df_pintar[df_pintar['r_value'] <= radius].copy()


def compute_od_green_pixels_fraction(df_vessel_pixels_OD, n_rows):
    """
    :param df_vessel_pixels_OD:
    :param n_rows:
    :return:
    """
    n_rows_pixels_fraction = df_vessel_pixels_OD.shape[0]
    pixels_fraction = n_rows_pixels_fraction / n_rows
    green_pixels_OD = df_vessel_pixels_OD[df_vessel_pixels_OD['type'] == 0].shape[0]
    return {
        'pixels_fraction': float(pixels_fraction),
        'od_green_pixel_fraction': float(green_pixels_OD / n_rows_pixels_fraction)
    }


def compute_neo_vascularization_od(df_pintar, OD_position):
    """
    :param df_pintar:
    :param OD_position:
    :return:
    """
    radius = 280
    n_rows = df_pintar.shape[0]
    df_vessel_pixels_OD = compute_vessel_radius_pixels(df_pintar, radius, OD_position)
    return compute_od_green_pixels_fraction(df_vessel_pixels_OD, n_rows)


def create_output_(out, imgfiles, function_to_execute, imgfiles_length):
    """
    :param out:
    :param imgfiles:
    :param function_to_execute:
    :param imgfiles_length:
    :return:
    """
    df = pd.DataFrame(out)
    df = df.set_index(imgfiles[:imgfiles_length])

    print(len(df), "image measurements taken")
    print("NAs per phenotype")
    print(df.isna().sum())
    output_path = os.path.join(
        phenotype_dir,
        f'{datetime.now().strftime("%Y-%m-%d")}_{function_to_execute}.csv',
    )

    df.to_csv(output_path)


if __name__ == '__main__':
    # command line arguments
    qcFile = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/noQC.txt'  # sys.argv[1] # qcFile used is noQCi, as we measure for all images
    phenotype_dir = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/OUTPUT/'  # sys.argv[2]
    lwnet_dir = '/Users/sortinve/PycharmProjects/pythonProject/sofia_dev/data/LWNET_DIR'  # sys.argv[4]
    # fuction_to_execute posibilities: 'tva', 'taa', 'bifurcations', 'green_segments', 'neo_vascularization', 'aria_phenotypes', 'fractal_dimension', 'ratios'
    fuction_to_execute = 'tva'  # sys.argv[5]
    filter_tva_taa = 1 if fuction_to_execute == 'taa' else (-1 if fuction_to_execute == 'tva' else None)
    # all the images
    imgfiles = pd.read_csv(qcFile, header=None)
    imgfiles = imgfiles[0].values

    # development param
    imgfiles_length = len(imgfiles)  # len(imgfiles) is default

    # computing the phenotype as a parallel process
    os.chdir(lwnet_dir)
    pool = Pool()

    if fuction_to_execute in {'taa', 'tva'}:
        imgages_and_filter = list(zip(imgfiles[:imgfiles_length], imgfiles_length * [filter_tva_taa]))
        out = pool.map(main_tva_or_taa, imgages_and_filter)
        # create_output_(out, imgfiles, fuction_to_execute, imgfiles_length) if out else print( "you didn't chosee any fuction")
    elif fuction_to_execute == 'bifurcations':
        out = pool.map(main_bifurcations, imgfiles[:imgfiles_length])
    elif fuction_to_execute == 'green_segments':
        out = pool.map(main_num_green_segment_and_pixels, imgfiles[:imgfiles_length])
    elif fuction_to_execute == 'neo_vascularization':
        out = pool.map(main_neo_vascularization_od, imgfiles[:imgfiles_length])
    elif fuction_to_execute == 'aria_phenotypes':
        out = pool.map(main_aria_phenotypes, imgfiles[:imgfiles_length])
    elif fuction_to_execute == 'ratios':
        out = pool.map(main_aria_phenotypes, imgfiles[:imgfiles_length])
    elif fuction_to_execute == 'fractal_dimension':
        out = pool.map(main_fractal_dimension, imgfiles[:imgfiles_length])
    else:
        out = None
    pool.close()
    create_output_(out, imgfiles, fuction_to_execute, imgfiles_length) if out else print(
        "You didn't chose any possible function. Options: tva, taa, bifurcations, green_segments,"
        " neo_vascularization, aria_phenotypes, fractal_dimension, or ratios.")

    if fuction_to_execute == 'ratios':  # For measure ratios as qqnorm(ratio)
        # To modify!
        DATE = datetime.now().strftime("%Y-%m-%d")

        df_data = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/"
                              "2021-12-28_ARIA_phenotypes.csv", sep=',')
        df_data = df_data[['Unnamed: 0', 'medianDiameter_artery', 'medianDiameter_vein', 'DF_artery', 'DF_vein']]
        df_data['ratio_AV_medianDiameter'] = df_data['medianDiameter_artery'] / df_data['medianDiameter_vein']
        df_data['ratio_VA_medianDiameter'] = df_data['medianDiameter_vein'] / df_data['medianDiameter_artery']
        df_data['ratio_AV_DF'] = df_data['DF_artery'] / df_data['DF_vein']
        df_data['ratio_VA_DF'] = df_data['DF_vein'] / df_data['DF_artery']

        df_data.to_csv(
            "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/" + DATE + "_ratios_ARIA_phenotypes.csv",
            sep=',', index=False)
