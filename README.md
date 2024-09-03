# CompleteR

R package for correcting completeness biases in metagenome-assembled genome functional inference.

## Quickstart

### Install and load the package

**CompleteR** can be installed from this same Github repository using the package `devtools`.

```r
install.packages("devtools")
library(devtools)
install_github("anttonalberdi/completer")
library(completer)
```

### Prepare reference data

Preparation of reference data entails generating some major one-time calculations to speed up future analyses. This step requires a few minutes and large amounts of memory, so be patient.

```r
setup_completer()
```

## Run imputation

Prepare the trait table and run the imputation.

### Load the tree outputed by GTDB-tk

Taxonomic annotation of bacterial genomes using GTDB-tk yields a phylogenetic tree including your target genomes as well as a number of reference genomes from the GTDB database. This tree is used as the link between the reference tree use by **CompleteR** for phylogenetic inference and your target genomes.

```r
lizard_tree <- read_tree("tests/lizards/gtdbtk.backbone.bac120.classify.tree")
```

In the case of our lizard-associated bacterial genome example the GTDB tree contains 4432 genomes, 4305 of which are GTDB reference genomes and 127 of which are our target genomes.

```
Phylogenetic tree with 4432 tips and 4430 internal nodes.

Tip labels:
  GB_GCA_001829155.1, GB_GCA_025061835.1, RS_GCF_900112165.1, GB_GCA_020059465.1, GB_GCA_023525255.1, GB_GCA_016214035.1, ...
Node labels:
  d__Bacteria, '99.0:p__Spirochaetota', 97.0, 34.0, '100.0:c__Brevinematia', '100.0:o__Brevinematales', ...

Unrooted; includes branch lengths.
```

### Load the gene annotation file

Any tabular format annotation file containing the annotations of interest, such as KEGG orthologs, Pfams or CAZYs. The annotation file might contain data from a single or multiple genomes.

```r
lizard_annotations <- read_tsv("tests/lizards/annotations.tsv.xz")
```

Our example is an annotation table generated by DRAM, which contains annotations of 88,350 genes predicted from out 25 focal genomes, with genome identifiers in column 2, and KEGG identifiers in column 9.

```
# A tibble: 88,350 × 24
   ...1      fasta scaffold gene_position start_position end_position strandedness rank  ko_id
   <chr>     <chr> <chr>            <dbl>          <dbl>        <dbl>        <dbl> <chr> <chr>
 1 all:bin_… all:… all:bin…             1              3          758           -1 C     K15856     
 2 all:bin_… all:… all:bin…             2            774         1805           -1 C     K01711           
 3 all:bin_… all:… all:bin…             3           1851         2930           -1 C     K00971      
 4 all:bin_… all:… all:bin…             4           2970         3947           -1 C     K18682
 5 all:bin_… all:… all:bin…             5           4681         6216           -1 C     K03565  
 6 all:bin_… all:… all:bin…             6           6654         7151           -1 C     K01921
```

### Generate the trait table

The original annotation file must be converted into a presence/absence trait table before conducting the imputation. The function ***annot_to_traits()*** does so if you indicate the columns in which the functional identifiers should be found. If the annotation file contains multiple genomes, the genome identifier column must also be indicated.

```r
lizard_traits <- annot_to_traits(annot=lizard_annotations,genome_index=2,kegg_index=9)
```

The resulting table contains the identifiers of our 25 focal genomes in the first column, and presence-absence data of 6303 KEGG orthologs in the subsequent columns.

```
# A tibble: 25 × 6,304
   genome          K00001 K00002 K00003 K00004 K00005 K00006 K00007 K00008 K00009
   <chr>            <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 Sg10:bin_000001      0      0      0      0      1      0      1      0      1
 2 Sg10:bin_000005      0      0      0      0      1      0      0      0      1
 3 Sg1:bin_000001       0      0      0      0      1      0      0      0      1
 4 Sg1:bin_000002       0      0      0      0      0      0      0      0      0
 5 Sg1:bin_000003       0      0      0      0      0      0      0      0      0
 6 Sg1:bin_000008       0      0      0      0      0      0      0      0      0
 7 Sg2:bin_000003       0      0      1      0      0      0      0      0      0
 8 Sg2:bin_000005       0      0      0      0      1      0      1      0      1
 9 Sg3:bin_000001       0      0      1      0      0      0      0      0      0
10 Sg3:bin_000002       0      0      1      0      0      0      0      0      0
```

### Conduct imputation

Now all the required data are ready to conduct the imputation.

```r
imputed_genomes <- completer(traits = lizard_traits, tree = lizard_tree)
```

The result of the imputation yields two pieces of information.

#### Imputed values

The attribute `imputation` yields the table with imputed values, with the trait identifiers in the first column, and genomes in the subsequent columns.

```
> imputed_genomes$imputation

# A tibble: 6,303 × 26
   trait  Sg10bin_000001 Sg10bin_000005 Sg1bin_000001 Sg1bin_000002 Sg1bin_000003
   <chr>           <dbl>          <dbl>         <dbl>         <dbl>         <dbl>
 1 K00001              0              0             0             0             0
 2 K00002              0              0             0             0             0
 3 K00003              0              0             0             0             0
 4 K00004              0              0             0             0             0
 5 K00005              1              1             1             0             0
 6 K00006              0              0             0             0             0
 7 K00007              1              0             0             0             0
 8 K00008              0              0             0             0             0
 9 K00009              1              1             1             0             0
10 K00010              0              0             0             0             0

```

#### Imputed values

The attribute `statistics` yields the a table with statistics of the imputation.

```
> imputed_genomes$statistics

# A tibble: 25 × 5
   genome          reference      distance scope sensitivity
   <chr>           <chr>             <dbl> <dbl>       <dbl>
 1 fecesbin_000038 GCF_0013182951     1.32 1.39        0.459
 2 Sg1bin_000002   GCF_0043456151     0.74 0.72        0.534
 3 allbin_000007   GCF_9000965651     0.71 0.808       0.483
 4 Sg1bin_000008   GCF_9000965651     0.7  0.808       0.527
 5 Sg9bin_000003   GCF_9000965651     0.7  0.808       0.52
 6 Sg9bin_000004   GCF_0022226152     0.12 0.167       0.729
 7 Sg9bin_000007   GCF_0022226152     0.17 0.167       0.67
 8 allbin_000070   GCF_0022226152     0.18 0.167       0.643
 9 Sg1bin_000003   GCF_9001785251     0.21 0.407       0.537
10 fecesbin_000066 GCF_9001785251     0.22 0.407       0.53
```


```r
cat_tree <- read_tree("tests/cats/gtdbtk.bac120.classify.tree")
cat_annotations <- read_tsv("tests/cats/annotations.tsv.xz")
cat_traits <- annot_to_traits(annot=cat_annotations,genome_index=2,kegg_index=9)
cat_imputed <- completer(traits = cat_traits, tree = cat_tree)

```
