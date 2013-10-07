---
layout: post
title: "Setting up a LAN with multiple gateway/interface with iptables and route policy under awesome Linux[2/2]"
date: 2013-03-17 10:48
comments: true
tags: [Linux Networking Route]
---

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Setting Up a LAN With Multiple Gateway/interface With Iptables and Route Policy Under Awesome Linux</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.sunus.me/blog/2013/03/17/setting-up-a-lan-with-multiple-gateway-slash-interface-with-iptables-and-route-policy-under-awesome-linux-2-slash-2/" property="cc:attributionName" rel="cc:attributionURL">sunus Lee</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.

# The Script of ArchLinux in solution Two #
{% include_code setArch.sh %}


# The Script of Route in final solution #

* see the **Working iptables rules** at here:
  * [https://gist.github.com/sunuslee/5179422](https://gist.github.com/sunuslee/5179422)
  * you probobly need to modify this file a little bit, or just create your own with ``iptables-save > filename``
  * make sure you have **PPP0-IP** in that file. because this script will replace **PPP0-IP** with the real **PPP0-IP** address.
  * you need to put the file working-iptables-rules along with setroute.sh, in the same directory.
  * if you are interested, those lines contain |sunus-a/b/c/d| are the Log, demonstration of how the packets went through all the way from one end to another.
  * this may have **bugs**, most likely.

{% include_code Setting the route setroute.sh %}
