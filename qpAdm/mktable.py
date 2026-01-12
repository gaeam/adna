import os
import re
import pandas as pd

# ======================
# 将 qpAdm 的 log 文件解析为 Excel 表格
# ======================
input_dir = "/Users/likexin/Desktop/qpAdm/WJD/"
output_excel = os.path.join(input_dir, "qpAdm.xlsx")

results = []

for fname in os.listdir(input_dir):
    # ✅ 只解析 log 文件
    if not fname.endswith(".log"):
        continue

    fpath = os.path.join(input_dir, fname)
    with open(fpath, "r") as f:
        text = f.read()

    # ---------- 必须包含 qpAdm 结果 ----------
    if "left pops:" not in text or "summ:" not in text:
        continue

    # ---------- left pops ----------
    left_match = re.search(r"left pops:\n([\s\S]*?)\n\n", text)
    if not left_match:
        continue

    left_pops = [x.strip() for x in left_match.group(1).split("\n") if x.strip()]
    target = left_pops[0]
    sources = left_pops[1:]
    way = len(sources)

    # ---------- coeffs ----------
    coef_match = re.search(r"coeffs:\s+([0-9.\s-]+)", text)
    coefs = list(map(float, coef_match.group(1).split())) if coef_match else []

    # ---------- std ----------
    std_match = re.search(r"std\. errors:\s+([0-9.\s-]+)", text)
    stds = list(map(float, std_match.group(1).split())) if std_match else []

    # ---------- P value ----------
    summ_match = re.search(r"summ:\s+\S+\s+\d+\s+([0-9.Ee+-]+)", text)
    pvalue = float(summ_match.group(1)) if summ_match else None

    row = {
        "target": target,
        "way": way,
        "Pvalue": pvalue,
        "file": fname
    }

    # ---------- sources / coefs / std ----------
    for i, src in enumerate(sources):
        row[f"source{i+1}"] = src
        row[f"coef{i+1}"] = coefs[i] if i < len(coefs) else None
        row[f"std{i+1}"] = stds[i] if i < len(stds) else None

    results.append(row)

# ---------- 导出 Excel ----------
df = pd.DataFrame(results)
df.to_excel(output_excel, index=False)

print(f"Done! Saved to {output_excel}")

