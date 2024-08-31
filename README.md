# COMPLETER

Software for correcting completeness biases in metagenome-assembled genome functional inference.

## GTDB reference genome fetching

The GTDB database was searched on the 31st of August 2024 for reference genome using the following advanced search string:

`("GTDB Taxonomy" CONTAINS "Bacteria" AND "CheckM2 Completeness" > "99" AND "CheckM2 Contamination" < "1" AND "GTDB Representative of Species" IS TRUE)`

- GTDB taxonomy contains Bacteria
- CheckM2 completeness is larger than 99%
- CheckM2 contamination is lower than 1%
- Is a GTDB representative species

The search returned 27942 entries:
