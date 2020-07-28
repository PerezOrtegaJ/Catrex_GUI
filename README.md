# Catrex GUI
GUI in MATLAB for automated **Ca**lcium **tr**ansients **ex**traction from imaging experiments.

1. Load tiff file with the sequence of images acquired.
2. Perform non-rigid (or rigid) motion correction.
3. Find cells based on Suite2P algorithm (Pachitariu et al., 2016).
4. Evaluate ROIs identified (area, circularity, perimeter, eccentricity and overlapping).
5. Extract calcium transients using local neuropil as the basal of fluorescence.
6. Evaluate peak signal-to-noise ratio (PSNR).
7. Perform spike inference (foopsi; Friedrich & Paninski, 2016).
8. Get raster activity, a binary matrix where each row is the activity of a single ROI.

Output of a structure variable with all data analyzed

## Author
**Jesús Pérez-Ortega**
