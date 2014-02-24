// nyc harbor depth (and surrounding area)

int N_W = 841; // number of points wide in depth_grid.csv
int N_H = 601; // number of points high in depth_grid.csv

int MIN = -42; // minimum z value in depth_grid.csv
int MAX = 213; // maximum z value in depth_grid.csv

int w = 800,
    h = 600,
    margin = 100;

float[][] depths = new float[N_W][N_H];

void setup() {
  size(w + 2*margin, h + 2*margin);
  translate(margin, margin);

  Table depth_grid_tab = loadTable("depth_grid.csv", "header");

  int j = 0;
  for ( TableRow row : depth_grid_tab.rows() ) {
    for (int i = 0; i < N_W; i++) {
      depths[i][j] = row.getInt(i);
    }
    j++;
  }

  // dimension reduction:
  // 1. skip every x entries
  // 2. local mean
  // 3. local median
  // 4. local min

  float x, y, d;

  float w_sq = 10, // container width
        d_min = 6, // min diameter for circle
        d_max = 13; // max diameter for circle

  int n_w = floor(w / w_sq), // number wide
      n_h = floor(h / w_sq), // number high
      n_skip_w = floor(N_W / n_w), // number of entries to skip horizontally
      n_skip_h = floor(N_H / n_h); // number of entries to skip vertically
  
  float[][] depth_plot = new float[n_w][n_h];

  for (int i = 0; i < n_h; i++) {
    for (j = 0; j < n_w; j++) {
      float[] depth_points = grid_square(depths, j, i, n_skip_w, n_skip_h);

      // 1. just skip over the requisite numbwer of entries
      // depth_plot[j][i] = depth_points[floor(n_skip_w*n_skip_h / 2)];
      
      // 2. local min
      depth_plot[j][i] = min(depth_points);

      // 3. local mean
      // for (int k = 0; k < depth_points.length; k++) {
      //   depth_plot[j][i] += depth_points[k];
      // }
      // depth_plot[j][i] = depth_plot[j][i] / depth_points.length;
    }
  }

  // plot
  background(255);
  smooth();
  color land = color(51, 117, 12);
  color water = color(34, 47, 163);
  for (int i = 0; i < n_h; i++) {
    y = w_sq/2 + i*w_sq;

    for (j = 0; j < n_w; j++) {
      x = w_sq/2 + j*w_sq;

      // if the comparison is <=, 0-depth points are water; if <, 0-depth is
      // considered land
      if (depth_plot[j][i] <= 0) {
        stroke(water);
        fill(water);
        d = map(depth_plot[j][i], MIN, 0, d_max, d_min);
      } else {
        stroke(land);
        fill(land);
        // d = map(depth_plot[j][i], 0, MAX, d_min, d_max);
        d = 5;
      }

      ellipse(x, y, d, d);
    }
  }
}

float[] grid_square(float[][] depths, int j, int i, int n_skip_w, int n_skip_h) {
  float[] points = new float[n_skip_w*n_skip_h];

  int k = 0;
  for (int ii = i*n_skip_h; ii < (i+1)*n_skip_h; ii++) {
    for (int jj = j*n_skip_w; jj < (j+1)*n_skip_w; jj++) {
      if (ii < N_H && jj < N_W) {
        points[k] = depths[jj][ii];
        k++;
      }
    }
  }
  return points;
}
