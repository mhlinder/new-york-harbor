// nyc harbor depth (and surrounding area)

int N_W = 841; // number of points wide in depth_grid.csv
int N_H = 601; // number of points high in depth_grid.csv

int MIN = -42; // minimum z value in depth_grid.csv
int MAX = 213; // maximum z value in depth_grid.csv

int w = 800,
    h = 600,
    margin = 100;

float bg = 255,
      fg = 0;

float[][] depths = new float[N_W][N_H];

void setup() {
  size(w + 2*margin, h + 2*margin);
  translate(margin, margin);

  background(bg);
  fill(bg);

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

  smooth();
  strokeWeight(3);
  textSize(12);


  float x, y, d;

  float w_sq = 15, // container width
        d_min = 2, // min diameter for circle
        d_max = 12; // max diameter for circle

  int n_w = floor(w / w_sq), // number wide
      n_h = floor(h / w_sq), // number high
      n_skip_w = floor(N_W / n_w), // number of entries to skip horizontally
      n_skip_h = floor(N_H / n_h); // number of entries to skip vertically

  for (int i = 0; i < n_h; i++) {
    y = w_sq/2 + i*w_sq;

    for (j = 0; j < n_w; j++) {
      x = w_sq/2 + j*w_sq;

      if (depths[j*n_skip_w][i*n_skip_h] < 0 ) {
        d = map(depths[j*n_skip_w][i*n_skip_h], MIN, 0, d_max, d_min);
      } else {
        d = 2;
      }

      println(depths[j][i]);
      ellipse(x, y, d, d);
    }
  }

}
