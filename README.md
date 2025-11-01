# 🖥️ Server Performance Stats – Bash Script

This is a beginner-friendly DevOps project that collects and displays important Linux server performance statistics using a Bash script. It helps monitor CPU, memory, disk usage, and processes efficiently from the command line.

---

## 📌 Features

The script provides the following system information:

✔ Total CPU Usage  
✔ Memory Usage (Used, Free, Percentage)  
✔ Disk Usage (Used, Free, Percentage)  
✔ Top 5 processes consuming most CPU  
✔ Top 5 processes consuming most Memory  
✔ Uptime (how long the system is running)  
✔ OS Version  
✔ Logged-in users count  

---

## 🛠️ Tech Stack / Commands Used

| Purpose | Tools/Commands |
|--------|----------------|
| CPU Usage | `top`, `grep`, `awk` |
| Memory Usage | `free`, `awk` |
| Disk Usage | `df`, `awk` |
| Process Stats | `ps`, `head`, `sort` |
| OS + Uptime info | `who`, `uptime`, `cat` |

These are important Linux system administration commands — very useful in DevOps.

---

## 🚀 How to Run the Script

Step 1️⃣: Clone or download project  
```bash
git clone https://github.com/<your-username>/server-performance-stats.git
cd server-performance-stats
