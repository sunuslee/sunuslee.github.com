---
layout: post
title: "Setting up a LAN with multiple gateway/interface with iptables and route policy under awesome Linux[2/2]"
date: 2013-03-17 10:48
comments: true
categories: 
tags: [Linux Networking, Route]
---

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Setting Up a LAN With Multiple Gateway/interface With Iptables and Route Policy Under Awesome Linux</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.sunus.me/blog/2013/03/17/setting-up-a-lan-with-multiple-gateway-slash-interface-with-iptables-and-route-policy-under-awesome-linux-2-slash-2/" property="cc:attributionName" rel="cc:attributionURL">sunus Lee</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.

# The Script of ArchLinux in solution Two #

<div class='bogus-wrapper'><notextile><figure class='code'><figcaption><span> (setArch.sh)</span> <a href='/./codes/setArch.sh'>download</a></figcaption>
 <div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
<span class='line-number'>21</span>
<span class='line-number'>22</span>
<span class='line-number'>23</span>
<span class='line-number'>24</span>
<span class='line-number'>25</span>
<span class='line-number'>26</span>
<span class='line-number'>27</span>
<span class='line-number'>28</span>
<span class='line-number'>29</span>
</pre></td><td class='code'><pre><code class='sh'><span class='line'><span class="c">#!/bin/bash</span>
</span><span class='line'>
</span><span class='line'><span class="k">if</span> <span class="o">[</span> <span class="sb">`</span>whoami<span class="sb">`</span> !<span class="o">=</span> <span class="s1">&#39;root&#39;</span> <span class="o">]</span>
</span><span class='line'><span class="k">then</span>
</span><span class='line'><span class="k">    </span><span class="nb">echo</span> <span class="s2">&quot;need root!&quot;</span>
</span><span class='line'>    <span class="nb">exit </span>1
</span><span class='line'><span class="k">fi</span>
</span><span class='line'>
</span><span class='line'><span class="c"># Change this to your interface name, could it be eth* or p*p*.</span>
</span><span class='line'><span class="nv">IFACE</span><span class="o">=</span><span class="s2">&quot;wlp4s0&quot;</span>
</span><span class='line'><span class="c"># Change this to your route addr.</span>
</span><span class='line'><span class="nv">ROUTE</span><span class="o">=</span><span class="s2">&quot;192.168.1.1&quot;</span>
</span><span class='line'><span class="c"># Change this to your vpn **Server addr**</span>
</span><span class='line'><span class="nv">VPNHOST</span><span class="o">=</span><span class="s2">&quot;221.239.126.9&quot;</span>
</span><span class='line'><span class="nv">VPNADDR</span><span class="o">=</span><span class="sb">`</span>ifconfig ppp0|grep -P -o <span class="s1">&#39;(?&lt;=inet )[0-9.]*&#39;</span><span class="sb">`</span>
</span><span class='line'><span class="nv">VPNROUTE</span><span class="o">=</span><span class="sb">`</span>ifconfig ppp0|grep -P -o <span class="s1">&#39;(?&lt;=destination )[0-9.]*&#39;</span><span class="sb">`</span>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;VPN-ADDR:&quot;</span><span class="nv">$VPNADDR</span>
</span><span class='line'><span class="nv">cmd</span><span class="o">=</span><span class="s2">&quot;ip route add $VPNHOST via $ROUTE dev $IFACE&quot;</span>
</span><span class='line'><span class="nb">echo</span> <span class="nv">$cmd</span>
</span><span class='line'><span class="nv">$cmd</span>
</span><span class='line'><span class="nv">cmd</span><span class="o">=</span><span class="s2">&quot;route add default gw $VPNROUTE&quot;</span>
</span><span class='line'><span class="nb">echo</span> <span class="nv">$cmd</span>
</span><span class='line'><span class="nv">$cmd</span>
</span><span class='line'><span class="nv">cmd</span><span class="o">=</span><span class="s2">&quot;route del default gw $ROUTE&quot;</span>
</span><span class='line'><span class="nb">echo</span> <span class="nv">$cmd</span>
</span><span class='line'><span class="nv">$cmd</span>
</span><span class='line'><span class="c"># The net is the route&#39;s subnet. be careful.</span>
</span><span class='line'>route add -net 192.168.1.0/24 gw 192.168.1.1
</span><span class='line'><span class="nb">echo</span> -e <span class="s1">&#39;nameserver 8.8.8.8\nsearch 8.8.4.4&#39;</span> &gt; /etc/resolv.conf
</span></code></pre></td></tr></table></div></figure></notextile></div>




# The Script of Route in final solution #

* see the **Working iptables rules** at here:
  * [https://gist.github.com/sunuslee/5179422](https://gist.github.com/sunuslee/5179422)
  * you probobly need to modify this file a little bit, or just create your own with ``iptables-save > filename``
  * make sure you have **PPP0-IP** in that file. because this script will replace **PPP0-IP** with the real **PPP0-IP** address.
  * you need to put the file working-iptables-rules along with setroute.sh, in the same directory.
  * if you are interested, those lines contain |sunus-a/b/c/d| are the Log, demonstration of how the packets went through all the way from one end to another.
  * this may have **bugs**, most likely.
  
<div class='bogus-wrapper'><notextile><figure class='code'><figcaption><span>Setting the route (setroute.sh)</span> <a href='/./codes/setroute.sh'>download</a></figcaption>
 <div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
<span class='line-number'>21</span>
<span class='line-number'>22</span>
<span class='line-number'>23</span>
<span class='line-number'>24</span>
<span class='line-number'>25</span>
<span class='line-number'>26</span>
<span class='line-number'>27</span>
<span class='line-number'>28</span>
<span class='line-number'>29</span>
<span class='line-number'>30</span>
<span class='line-number'>31</span>
<span class='line-number'>32</span>
<span class='line-number'>33</span>
<span class='line-number'>34</span>
<span class='line-number'>35</span>
<span class='line-number'>36</span>
<span class='line-number'>37</span>
</pre></td><td class='code'><pre><code class='sh'><span class='line'><span class="c">#!/bin/sh</span>
</span><span class='line'>
</span><span class='line'>
</span><span class='line'><span class="nv">SUNUS_IP</span><span class="o">=</span><span class="s1">&#39;192.168.1.169&#39;</span>
</span><span class='line'><span class="nv">VPN_ROUTE</span><span class="o">=</span><span class="sb">`</span>ifconfig ppp0|grep -o <span class="s1">&#39;P-t-P:[0-9.]*&#39;</span>|tr -d <span class="s1">&#39;P-t-P:&#39;</span><span class="sb">`</span>
</span><span class='line'><span class="nv">VPN_IP</span><span class="o">=</span><span class="sb">`</span>ifconfig ppp0|grep -o <span class="s1">&#39;addr:[0-9.]*&#39;</span>|tr -d <span class="s1">&#39;addr:&#39;</span><span class="sb">`</span>
</span><span class='line'><span class="nv">TMP_RULES_FILE</span><span class="o">=</span><span class="s1">&#39;/tmp/TRF&#39;</span>
</span><span class='line'><span class="nv">ROUTE_TABLE</span><span class="o">=</span><span class="s1">&#39;sunusroute&#39;</span>
</span><span class='line'><span class="k">if</span> <span class="o">[</span> <span class="s2">&quot;$VPN_ROUTE&quot;</span> <span class="o">=</span> <span class="s2">&quot;&quot;</span> -o <span class="s2">&quot;$VPN_IP&quot;</span> <span class="o">=</span> <span class="s2">&quot;&quot;</span> <span class="o">]</span>
</span><span class='line'><span class="k">then</span>
</span><span class='line'><span class="k">  </span><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'>  <span class="nb">echo</span> <span class="s2">&quot;No VPN-Connection&quot;</span>
</span><span class='line'>  <span class="nb">echo</span> <span class="s2">&quot;Make sure your xl2tp is working&quot;</span>
</span><span class='line'>  <span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'>  <span class="nb">exit </span>1
</span><span class='line'><span class="k">fi</span>
</span><span class='line'>
</span><span class='line'>sed <span class="s2">&quot;s/PPP0-IP/$VPN_IP/&quot;</span> working-iptables-rule &gt; <span class="nv">$TMP_RULES_FILE</span>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;VPN-ROUTE:&quot;</span><span class="nv">$VPN_ROUTE</span>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;VPN-ADDR:&quot;</span><span class="nv">$VPN_IP</span>
</span><span class='line'>
</span><span class='line'>ip route add default via <span class="nv">$VPN_ROUTE</span> dev ppp0 table <span class="nv">$ROUTE_TABLE</span>
</span><span class='line'>ip rule add from <span class="nv">$SUNUS_IP</span> table <span class="nv">$ROUTE_TABLE</span>
</span><span class='line'>ip route flush cache
</span><span class='line'>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;setting ip rules and route-policy successfully&quot;</span>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'>iptables-restore &lt; <span class="nv">$TMP_RULES_FILE</span>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;setting iptables successfully&quot;</span>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span><span class='line'><span class="nb">echo</span> <span class="s2">&quot;NOW SUNUS CAN USING THE VPN CONNECTING!&quot;</span>
</span><span class='line'><span class="nb">echo</span> -e <span class="s2">&quot;\n*********\n&quot;</span>
</span></code></pre></td></tr></table></div></figure></notextile></div>

