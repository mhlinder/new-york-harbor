// nyc harbor depth (and surrounding area)

int N_W = 841; // number of points wide in depth_grid.csv
int N_H = 601; // number of points high in depth_grid.csv

int MIN = -42; // minimum z value in depth_grid.csv
int MAX = 213; // maximum z value in depth_grid.csv

int w = 800,
    h = 600,
    margin = 40;

float[][] depths = new float[N_W][N_H];

void setup() {
  size(w + 2*margin, h + 2*margin);
  translate(margin, margin);

  Table depth_grid_tab = loadTable("depth_grid.csv", "header");

  // load depths from file
  int j = 0;
  for ( TableRow row : depth_grid_tab.rows() ) {
    for (int i = 0; i < N_W; i++) {
      depths[i][j] = row.getInt(i);
    }
    j++;
  }

  float w_sq = 5, // point container width
        d_min = .9 * w_sq, // min diameter for point
        d_max = 1.5 * w_sq; // max diameter for point

  int n_w = floor(w / w_sq), // number wide
      n_h = floor(h / w_sq), // number high
      n_skip_w = floor(N_W / n_w), // number of entries to skip horizontally
      n_skip_h = floor(N_H / n_h); // number of entries to skip vertically
  
  float[][] depth_plot = new float[n_w][n_h];

  // calculate depth value for each point
  for (int i = 0; i < n_h; i++) {
    for (j = 0; j < n_w; j++) {
      float[] depth_points = grid_square(depths, j, i, n_skip_w, n_skip_h);

      // 1. look at "middle" point
      // depth_plot[j][i] = depth_points[floor(n_skip_w*n_skip_h / 2)];
      
      // 2. local min
      // depth_plot[j][i] = min(depth_points);

      // 3. local mean
      for (int k = 0; k < depth_points.length; k++) {
        depth_plot[j][i] += depth_points[k];
      }
      depth_plot[j][i] = depth_plot[j][i] / depth_points.length;
    }
  }

  // plot
  background(255);
  smooth();
  noStroke();

  color water = color(15, 39, 120);
  color land = color(0, 0, 0);

  float x, y, d;

  for (int i = 0; i < n_h; i++) {
    y = w_sq/2 + i*w_sq;

    for (j = 0; j < n_w; j++) {
      x = w_sq/2 + j*w_sq;

      // if the comparison is <=, 0-depth points are water; if <, 0-depth is
      // considered land
      if (depth_plot[j][i] <= 0) {
        fill(water);
        d = map(depth_plot[j][i], MIN, 0, d_max, d_min);
      } else {
        fill(land);
        // d = map(depth_plot[j][i], 0, MAX, d_min, d_max);
        d = d_min - 2;
      }

      ellipse(x, y, d, d);
    }
  }

  save("water.png");
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
