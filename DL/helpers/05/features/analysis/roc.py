import numpy as np
import os
from sklearn.metrics import roc_curve, auc
from sklearn.metrics import roc_auc_score
from custom_modules import GetData
import matplotlib.pyplot as plt

def perform_roc(data,pred_idx,legend_label):
    pred_data = np.asarray(data[:,pred_idx],dtype=float)
    label = np.asarray([d.replace("tensor([","").replace("])","") for d in data[:,-2]],dtype=float)
    #print(pred_data,label)
    fpr, tpr, thresholds = roc_curve(label,pred_data)
    auc_value = auc(fpr, tpr)
    plt.scatter(fpr, tpr,alpha=0.55,label=legend_label+" (auc:"+str(np.round(auc_value,3))+", #points: "+str(len(pred_data))+")")

def random_plot(data):
    plt.plot(np.linspace(0,1,len(data)),np.linspace(0,1,len(data)),color="red",label="random (auc: 0.5)")

if __name__ == "__main__":
    prediction = GetData.get("../output/prediction.out",numpy=True,header=True)
    prediction_train = prediction[np.where(prediction[:,-1] == "train")[0]]
    prediction_val = prediction[np.where(prediction[:,-1] == "val")[0]]
    perform_roc(prediction_train,1,'train')
    perform_roc(prediction_val,1,'val')
    random_plot(prediction_val)
    plt.title("First prediction value")
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.legend()
    plt.savefig("ROC_AUC_MODEL_PREDICTION_VAL_1.png")
    plt.close()
    perform_roc(prediction_train,2,'train')
    perform_roc(prediction_val,2,'val')
    random_plot(prediction_val)
    plt.title("First prediction value")
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.legend()
    plt.savefig("ROC_AUC_MODEL_PREDICTION_VAL_2.png")
    plt.close()
