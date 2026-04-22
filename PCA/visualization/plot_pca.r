# 载入所需的库
library(ggplot2)
library(cowplot)
library(plotly)
library(htmlwidgets)
# library(grid) # 仅在需要直接调用 grid::grid.draw 时才需要

# --- 1. 配置和文件路径 ---
# 使用 list 存储路径，方便管理
# evec 是通过 log2txt.sh 生成的
# eval 是通过 smartpca 生成的，直接读取
file_paths <- list(
  evec = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/GGVD_232_VarGoats_1372_common.evec.txt",
  eval = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/GGVD_232_VarGoats_1372_common.eval",
  style = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/group_styles.csv",
  html_out = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/GGVD_232_VarGoats_1372_common_pca_interactive.html",
  png_out = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/GGVD_232_VarGoats_1372_common_pca_plot.png",
  legend_out = "~/Desktop/goat/nuclear/PCA/GGVD_VarGoats_common/GGVD_232_VarGoats_1372_common_pca_legend.png"
)

# 增加一个检查文件是否存在的函数，提高健壮性
check_file_exists <- function(path_list) {
  for (name in names(path_list)) {
    if (!file.exists(path_list[[name]]) && name != "html_out" && name != "png_out" && name != "legend_out") {
      stop(paste("Error: Required input file not found:", path_list[[name]]))
    }
  }
}
check_file_exists(file_paths)


# --- 2. 数据读取与预处理 ---

# 载入 PCA 投影数据（evec 文件）
df <- read.table(file_paths$evec, header = FALSE, stringsAsFactors = FALSE)

# 载入 eigenvalues 文件并计算方差解释度
eigenvals <- scan(file_paths$eval, quiet = TRUE)
explained_var <- eigenvals / sum(eigenvals) * 100

# PC1 和 PC2 的解释度（保留 2 位小数）
pc1_var <- round(explained_var[1], 2)
pc2_var <- round(explained_var[2], 2)

# 规范化列名
# 假设 VCF 格式的 PCA 输出：第一列是样本 ID，最后一列是群体标签
colnames(df) <- c("sample", paste0("PC", 1:(ncol(df) - 2)), "label")


# --- 3. 载入和应用样式映射 ---

styles <- read.csv(file_paths$style, header = TRUE, stringsAsFactors = FALSE)

# 使用 dplyr 风格的管道（虽然此处非必需，但更具现代 R 风格）
df <- df |>
  # 将样式数据合并到主数据框中
  dplyr::left_join(styles, by = c("label" = "pop")) |>
  # 确保颜色和形状列名为 'color' 和 'shape' (或保留 styles.color, styles.shape)
  dplyr::rename(color_code = color, shape_code = shape)

# 准备 scale_manual 的映射向量
color_map <- setNames(df$color_code, df$label)
shape_map <- setNames(df$shape_code, df$label)


# --- 4. 绘制静态图 ---

p_static <- ggplot(df, aes(x = PC1, y = PC2, color = label, shape = label,
                           # 定义 Plotly 交互式提示文本
                           text = paste0(
                             "Sample: ", sample,
                             "<br>Group: ", label,
                             "<br>PC1: ", format(PC1, digits = 4), # 使用 format 保持精度
                             "<br>PC2: ", format(PC2, digits = 4)
                           )
)) +
  geom_point(size = 2, alpha = 0.8) +
  # 使用去重后的映射向量
  scale_color_manual(values = color_map[!duplicated(names(color_map))]) +
  scale_shape_manual(values = shape_map[!duplicated(names(shape_map))]) +
  labs(title = "PCA of GGVD_VarGoats_common",
       x = paste0("PC1 (", pc1_var, "%)"),
       y = paste0("PC2 (", pc2_var, "%)"),
       color = "Population", # 显式命名图例标题
       shape = "Population") +
  theme_classic() +
  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold") # 图例标题加粗
  )


# --- 5. 交互式图表和图例分离 ---

# 转换为交互式图
p_interactive <- ggplotly(p_static, tooltip = "text")

# 分离图例对象
legend_grob <- cowplot::get_legend(p_static)

# 生成无图例的静态图
p_no_legend <- p_static + theme(legend.position = "none")


# --- 6. 结果保存 ---

# 保存交互式 HTML 文件
saveWidget(p_interactive, file = file_paths$html_out, selfcontained = TRUE)
cat(paste("Interactive PCA plot saved to:", file_paths$html_out, "\n"))

# 保存无图例的静态散点图
ggsave(file_paths$png_out, p_no_legend, width = 6, height = 6, dpi = 300)
cat(paste("Static PCA plot saved to:", file_paths$png_out, "\n"))


# 保存图例
# 注意：直接使用 ggsave 保存 legend_grob 现代 R 中更推荐，但为了兼容旧代码结构，保留 png/grid.draw 方式
png(file_paths$legend_out, width = 3000, height = 800, res = 150)
grid::grid.draw(legend_grob)
dev.off()
cat(paste("PCA legend saved to:", file_paths$legend_out, "\n"))

