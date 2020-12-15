Run demo.py and if it runs all the way through with no errors the code works.  The demo shows some examples of simple distributions being reconstructed with partial knowledge and a maximum entropy assumption, that all non-observables are maximumally random.

Step1 performs some cosmetic renaming and data prepping from the original Total_data csv.
Step2 identifies winners/losers and creates matrix based on teams within a league over a given year.
Step3 concats division alignments throughout years.
Step4 merges and cleans division data with game result data.
Step5 creates win/loss pct matrix by division (23 Nov: still need to make iterative over divisions)
Step6 wrangles playoff data
