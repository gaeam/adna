library(ggplot2)
library(cowplot)
library(plotly)
library(htmlwidgets)

# === 载入 PCA 数据 ===
evec_file <- "~/Desktop/cattle.smartpca.projection.evec.txt"
df <- read.table(evec_file, header = FALSE, stringsAsFactors = FALSE)

# 读取 eigenvalues 文件

eval_file <- "~/Desktop/cattle.smartpca.projection.eval"
eigenvals <- scan(eval_file)

# 计算方差解释度
explained_var <- eigenvals / sum(eigenvals) \* 100

# PC1 和 PC2 的解释度（保留 2 位小数）
pc1_var <- round(explained_var[1], 2)
pc2_var <- round(explained_var[2], 2)

# 假设最后一列是群体标签
colnames(df) <- c("sample", paste0("PC", 1:(ncol(df)-2)), "label")

# === 载入样式映射文件 ===
style_file <- "~/Desktop/group_styles.csv"
styles <- read.csv(style_file, header = TRUE, stringsAsFactors = FALSE)

# 转换成 ggplot2 需要的映射
df$color <- styles$color[match(df$label, styles$pop)]
df$shape <- styles$shape[match(df$label, styles$pop)]

# === 主图（带图例） ===
p <- ggplot(df, aes(x = PC1, y = PC2, color = label, shape = label,text = paste0(
"Sample: ", sample,
"<br>Group: ", label,
"<br>PC1: ", round(PC1, 4),
"<br>PC2: ", round(PC2, 4)
)
)) +
geom_point(size = 2, alpha = 0.8) +
scale_color_manual(values = setNames(styles$color, styles$pop)) +
scale_shape_manual(values = setNames(styles$shape, styles$pop)) +
labs(title = "PCA of Cattle", x = paste0("PC1 (", pc1_var, "%)"), y = paste0("PC2 (", pc2_var, "%)")) +
theme_classic() +
theme(
legend.position = "right",
legend.title = element_blank()
)

# === 转换为交互式图 ===
p_interactive <- ggplotly(p, tooltip = "text")

# === 分离图例 ===
legend <- cowplot::get_legend(p)
p_no_legend <- p + theme(legend.position = "none")

# === 保存为 HTML 文件 ===
out_file <- "~/Desktop/pca_interactive.html"
saveWidget(p_interactive, file = out_file, selfcontained = TRUE)

# === 保存散点图 ===
ggsave("~/Desktop/pca_plot.png", p_no_legend, width = 6, height = 6, dpi = 300)

# === 保存图例 ===
png("~/Desktop/pca_legend.png", width = 3000, height = 800, res = 150)
grid::grid.draw(legend)
dev.off()