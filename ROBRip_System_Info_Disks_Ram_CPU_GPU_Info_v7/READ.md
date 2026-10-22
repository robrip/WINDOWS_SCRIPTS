\# \*\*\ROBRip_System_Diagnostics_v7.ps1\*\*  

\### \*\*Neon‑Violet Hardware Telemetry \& System Health Scanner\*\*



ROBRip System Diagnostics v7 is a \*\*PowerShell-based hardware telemetry suite\*\* designed to give you a \*\*full snapshot of your system’s health\*\*, storage configuration, GPU VRAM, live GPU load, CPU usage, memory usage, SMART reliability indicators, and more — all wrapped in a neon‑violet banner aesthetic.



This script is built for \*\*clarity\*\*, \*\*speed\*\*, and \*\*diagnostic depth\*\*, making it ideal for troubleshooting, benchmarking, or validating system health across Windows machines.



\---



\## \*\*✨ Features Overview\*\*



\### \*\*🎨 Neon‑Violet Banner\*\*

A custom ANSI-styled banner prints at launch, giving the script its signature identity.



> From the script:  

> \*“Neon‑Violet ROBRip Banner”\*  

> \*“██████╗  ██████╗ ██████╗ ██████╗  ██╗██████╗”\*  





\---



\## \*\*🧠 Core Modules\*\*



\### \*\*1. Disk Health \& Type Detection\*\*

Automatically identifies disk type using friendly-name heuristics:



\- ⚡ NVMe  

\- 🔷 SSD  

\- 💽 HDD  

\- 🖴 USB / Flash



> The script detects NVMe via BusType or model patterns such as `NVMe`, `MZVL`, `Lexar NM`, `X7400`.  





\---



\### \*\*2. GPU VRAM Parsing (DXDIAG XML)\*\*

Parses `dxdiag` output to extract:



\- Dedicated VRAM  

\- Shared VRAM  

\- Total VRAM  

\- Driver version  

\- Duplicate GPU entries automatically removed



> Uses DXDIAG XML and converts MB → GB with rounding.  





\---



\### \*\*3. Live GPU Stats (NVIDIA Only)\*\*

If `nvidia-smi` is available, the script displays:



\- GPU load (%)  

\- Temperature (°C)  

\- VRAM used / total  

\- GPU name  



> If `nvidia-smi` is missing, the script gracefully reports:  

> \*“GPU live stats: nvidia-smi not found in PATH.”\*  





\---



\### \*\*4. Disk \& Partition Mapping\*\*

Enumerates all partitions with drive letters and prints:



\- Disk number  

\- Friendly name  

\- Serial number  

\- Health status  

\- Operational status  

\- Size (GB)  

\- Partition style  



Color-coded output based on health:



\- Green → Healthy  

\- Yellow → Warning  

\- Red → Unhealthy  



\---



\### \*\*5. Disk Space Summary\*\*

Shows used and free space for all mounted drives.



\---



\### \*\*6. SMART / Reliability Indicators\*\*

Pulls reliability counters when available:



\- Temperature  

\- Wear  

\- Read errors  

\- Write errors  

\- Reallocated sectors  



Gracefully handles systems without SMART exposure.



\---



\### \*\*7. CPU Usage\*\*

Displays CPU model and current load percentage.



\---



\### \*\*8. Memory Usage\*\*

Shows total visible memory and free physical memory (GB).



\---



\### \*\*9. GPU Information Summary\*\*

Outputs GPU VRAM and driver info in a formatted table.



\---



\### \*\*10. Optional Temperature Module (Disabled)\*\*

A WMI-based thermal zone reader is included but commented out due to inconsistent support across systems.



\---



\## \*\*📦 Requirements\*\*



\- Windows 10/11  

\- PowerShell 5+  

\- Optional: `nvidia-smi` for live GPU telemetry  

\- DXDIAG (built into Windows)



\---



\## \*\*🚀 How to Run\*\*



1\. Save the script as:  

&#x20;  `ROBRip_System_Diagnostics_v7.ps1`



2\. Open PowerShell \*\*as Administrator\*\*.



3\. Run the script:



```powershell

.\ROBRip_System_Diagnostics_v7.ps1

```



If execution policy blocks the script:



```powershell

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

```



\---



\## \*\*📊 Output Format\*\*



The script prints structured sections:



\- \*\*GPU Live Stats\*\*  

\- \*\*Physical Disk \& Partition Info\*\*  

\- \*\*Disk Space Information\*\*  

\- \*\*SMART / Reliability\*\*  

\- \*\*CPU Usage\*\*  

\- \*\*Memory Usage\*\*  

\- \*\*GPU Information\*\*  



Each section is clearly labeled and formatted for readability.



\---



\## \*\*🧬 Branding\*\*



The script ends with:



> \*“ClaudeWad DIAGNOSTICS v6 — telemetry engaged.”\*  





This is part of the evolving ROBRip diagnostic suite identity.



\---



\## \*\*📘 Version\*\*



\*\*ROBRip Diagnostics v7\*\*  

Latest revision includes:



\- Improved NVMe/SSD/HDD detection  

\- Enhanced DXDIAG parsing  

\- Better GPU duplicate filtering  

\- More reliable SMART handling  

\- Neon‑violet banner refinements  



\---

🎨 Branding
Part of the CLAUDEWAD / ROBRip suite — neon‑loud, forensic, unapologetically diagnostic.

📄 License
ROBRip OpenSource

