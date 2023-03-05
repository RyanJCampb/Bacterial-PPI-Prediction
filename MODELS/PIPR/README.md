**[PIPR](https://github.com/muhaochen/seq_ppi)**  
Muhao Chen, Chelsea J -T Ju, Guangyu Zhou, Xuelu Chen, Tianran Zhang, Kai-Wei Chang, Carlo Zaniolo, Wei Wang, Multifaceted protein–protein interaction prediction based on Siamese residual RCNN, Bioinformatics, Volume 35, Issue 14, July 2019, Pages i305–i314, https://doi.org/10.1093/bioinformatics/btz328  
___
## Usage:  

e.g.  
> **CUDA_VISIBLE_DEVICES=0 python pipr_rcnn.py all_sequences.fasta dataTrain.tsv dataTest.tsv**  

1. Sequences file must contain all protein IDs and sequences from train and test data in .tsv format, 
eg:  
> PROTEINA  SEQUENCEASLSFPVTSSMVSSTSSYSSFLFLLVSGPLNHNISPFVFFH  
> PROTEINB	TQMTSEQUENCEBPAPKISYKFVRSLVREIAGLSPYKRLGSFTRAKAKVERH  
> PROTEINC	DLATKINEKPSEQUENCECTVVNDYEAAVLSKLERAAPK  

2. Train data must contain protein IDs and labels (1=interacts, 0=does not interact) and be in .tsv with a header, 
eg:  
> v1	v2	label  
> PROTEINA	PROTEINA	1  
> PROTEINA	PROTEINB	1  
> PROTEINB	PROTEINC	1  
> PROTEINX	PROTEINA	0  
> PROTEINY	PROTEINB	0  
> PROTEINA	PROTEINZ	0  

Test data must be in the same format as train data.  

<i>Note 1: if train data and test data args are the same, a 5-fold cross-validation will be performed on the provided data.</i>  
<i>Note 2: Make sure embeddings/ is in the same directory as pipr_rcnn.py</i>  
<i>Note 3: -c or --cpu option will not run the model</i>  

### Transfer Learning:

To perform transfer learning on PIPR from human to e. coli, follow these steps:

```bash
# Create new model, train on human data and save
set CUDA_VISIBLE_DEVICES=0 & python3 pipr_rcnn.py --save_model human_all_sequences.fasta human_train_data.tsv human_test_data.tsv

# Load human trained model, freeze last few layers, train on ecoli data, unfreeze and save
set CUDA_VISIBLE_DEVICES=0 & python3 pipr_rcnn.py --load_model saved_human.model --trainable_layers 5 --transfer_learning --save_model ecoli_all_sequences.fasta ecoli_train_data.tsv ecoli_test_data.tsv

# Finetune ecoli model by retraining with all layers unfrozen using ecoli data and low learning rate, then save
set CUDA_VISIBLE_DEVICES=0 & python3 pipr_rcnn.py --load_model saved_ecoli.model --learning_rate 1e-5 --transfer_learning --save_model ecoli_all_sequences.fasta ecoli_train_data.tsv ecoli_test_data.tsv
```

You can find an example TL script that runs TL on 5-fold CV datasets which can be run on Compute Canada here [`example-tl-job/pipr_job_tl_example.sh`](example-tl-job/pipr_job_tl_example.sh)

### Requirements:
python 2.7 or 3.6  
Tensorflow 1.7 (with GPU support)  
CuDNN  
Keras 2.2.4  
