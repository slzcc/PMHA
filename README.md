# PMHA
### Prevent Malicious HTTP Access
使用 TCPDump 抓取服务器正在被访问的 `host` 如果发现恶意访问 `恶意访问的定义是 Client 不停地发送 TCP 握手中 SEQ 报头` SEQ 的报头在 TCPDump 抓取时会以 `[S]` 展示。

在抓取的文件中 `每 10 分钟抓取 2000 行数据` 如果此时间段内的 Client 发起的 SEQ 报头超过 `20` 次，则记录在内，并通过 iptables 每 10 分执行一次，把新抓取的 Client IP 记录在内。

请在 CronJob 内写入自己所需的执行间隔:
```
*/10 * * * * /root/PMHA/malice_access.sh
*/10 * * * * /root/PMHA/main.sh start
```
文件 malice_access.sh 执行了 TCPDump 的抓包工作, 请自定义修改 host 和抓取包的行数：
```
HostIP="101.200.83.130"
...
tcpdump -i eth1 -nn host ${HostIP} and ! port 22 and ! icmp -c 2000  >>  ${CapFile}
```
如果满足需求请不要擅自删除某个特定文件，目前这个脚本只适用于测试, 但已经对 wiki.shileizcc.com 网站进行绑定。

对特定 IP 的可以设置白名单, 请写入 neglect_list.txt 文件一行一个 IP 地址，不支持其他格式：
```
8.8.8.8
```
