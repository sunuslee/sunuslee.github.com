---
layout: post
title: "Setting up a LAN with multiple gateway/interface with iptables and route policy under awesome Linux[1/2]"
date: 2013-03-16 22:09
comments: true
categories: 
tags: [Linux Networking, Route]
---

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Setting Up a LAN With Multiple Gateway/interface With Iptables and Route Policy Under Awesome Linux</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.sunus.me/blog/2013/03/16/setting-up-a-lan-with-multiple-gateway-slash-interface-with-iptables-and-route-policy/" property="cc:attributionName" rel="cc:attributionURL">sunus Lee</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.

# Introduction #
First of all, it all because my MacBookPro's xl2tp utils can not work under my school's networking enviroment. so this is how the post is born.

I have been digging with those stuffs for almost a week, and now, finally i get it rolling and it seems awesome. this post will talks about netfilter known as iptables and ip route policy. and some technic/tool like tcpdump will be involved as well.

# Environment #

The environment i have is like this below:




    -----------------    -----------------
    | Slow          |    | Fast          |
	| Internet-1    |    | Internet-2    |
	| 10.10.149.1   |    | 123.150.232.1 |
	-----------------    -----------------
			 |             |
	[eth0.2] |             |[ppp0]
			 |             |
			--------------------------
			| Route, Running Linux   |
			| br-lan: 192.168.1.1    | [br-lan]      ------------------------
			| ppp0:   123.150.232.74 | --------------| Other Machines in Lan|
			| eth0.2: 10.10.149.4    |               ------------------------
			--------------------------
			|                        |
	[br-lan]|                        |[br-lan]
			|                        |
			|                        |
			|                        |
      -------------------------      ----------------------
      |ArchLinux              |      | MacBook            |
      |eth0: 192.168.1.245    |      | en0:192.168.1.169  |
      |ppp0: 180.134.135.173  |      |                    |
      -------------------------      ----------------------
            |
            |
            |
            |
      ------------------
      | Fast           |
      | Internet-3     |
      | 180.134.135.1  |
      ------------------
            
            
            
   after connect the wires. there is three ** physic wires **:

*  **Route** <------> **Slow Internet-1 **this is the only one that connects to outside my dorm. via route's port WAN.
*  **Route** <------> ** ArchLinux ** this one is in a Route's port #1 LAN
*  **Route** <------> ** MacBook ** same as above, using Route's port #2 LAN
   
  There is also something to be noticed:

*  the **ppp0** in **Route** is a high-speed connection(VPN). it needs to go though **eth0.2** to connect the VPN-server, then it will generate a Virtual Network InterFace, that is, ppp0.
 
*  the another **ppp0** in **ArchLinux** is also the high-speed connection. but firstly, it goes to **Route**, then the VPN-server.
 
*  in this environment, you can consider those ppp0 as real NICs that are connected to the internet as well.
 
*  So, we can say eth0.2 and two ppp0 are all outgoing Interfaces.


# Solutions #

  *    I repeat what i want to accomplished here:
       
       1 .    i want my MacBook can connected to the internet.
       
       2 .    i want my MacBook's internet connection to be as **FAST** as possible.
  
  *    Before we get started, there's something we can do and can't do, in general.
       
       1 .    Seting the **default route** to 180.134.135.1 for ArchLinux and a route to lan. We do this because we want all the trafftic goes to a fast internet connecting while we keep the connection to the other machines in the lan still work.
       
        # route add -net 192.168.1.0/24 gw 192.168.1.1 dev eth0
        # route add default gw 180.134.135.1 dev ppp0

       2 .    Because there is other machines in the lan, so we can not set 123.150.232.1 as **default route** for Route, just like the ArchLinux. there is only ** me ** can access the Fast Internet-2.( The **Benefit** of being me or with me :) lol! )
       
## The Slow Solution ##
   
  *    Making the MacBook can connect to the internet, but it just too slow for me. Just set up machines and route like the diagram above, it will result this:
       
       1 .  the ArchLinux using Internet-3.
   
       2 .  the MacBookPro using Slow-Internet-1
       
## The A Little Bit Faster Solution ##
  
  *    Making the MacBook Using ArchLinux's Internet-3 and the ArchLinux still keep unchanged in Slow Solution. This solution requires those steps.
       
      *   in the MacBook, change default route from 192.168.1.1 to 192.168.1.245
       
         In MacBook:
         # route add default 192.168.1.245
         # route del default 192.168.1.1
         
      
      *   in ArchLinux, set up a route policy/rule
      
           *  the packets that comes from MacBook(192.168.1.169), Using the gateway of Internet-3.
                 
         
                In ArchLinux:
                # add a empty table to route table
                echo '7375 SunusRules' >> /etc/iproute2/rt_tables
                # add a default route rule to newly create table SunusRules
                ip route add default via 180.134.135.173 dev ppp0 table SunusRules
                # add this table to routing rules, all the packet comes from MacBook, apply this route rule.
                ip rule add from 192.168.1.169 table SunusRules
                
           * We are done here.
           
           * In fact, i don't think add a route rule here is necessarily, but anyway, it's a good time to get the first impression of what this can do. which we will make the best use of it in next Solution.
           
## The Ultimate And More Fast Solution, so far ##
  *    As you may think, why we still didn't use Fast-Internet-2 yet. Now, it's time to rolling on this connection! Let the MacBook and only MacBook use this connection.
  
       * In fact, this is a kinda complicated process, we need to do the following stuffs to put it all together to work properly.
       
         1 . Leave MacBook's default (192.168.1.1) untouched.
         
         2 . Let the Route know, if a packet is come from MacBook(192.168.1.169), sets the **Gateway** of this connection to 1123.150.232.1 and **Outgoing Interface** to ppp0. because at this point, only ppp0 can connect to it's **Gateway**(123.150.232.1)
              
         *    **policy routing** is the first magic.
              * as most of us might already knew that, the linux kernel only allow exactly one **efficient default** in **route table**.
              * so this needs is beyond a simple ``route`` command can do. but, don't worry. net-tools is out of date for so long, let us introduce the new `ip` tools to do this for us.
              * basically, this is still maintain that one kernel default route in route table, but, it allow us to add custom route table based on our needs, and set up the right condition. e.g **the packet's source address/net** or **the incoming interface**, etc see ``ip route help``.
                * the steps to make this happened are:
                  
                      # add a table id and table name to the route table database, just make sure they are unique.
                      echo '7375 sunusroute' >> /etc/iproute2/rt_tables
                      # check if that succeeded, the out should be empty.
                      ip route show table sunusroute
                      # then, add route rules to this newly create table.
                      # set the default route/gateway of this table
                      ip route add default via 123.150.232.1 dev ppp0
                      # finally, add a rule to tell the kernel, under what circumstance,
                      the packet should use the route table from what we just set,
                      instead of the default route rules. we just set this simple rule, if a packet is from 192.168.1.169, then apply the rules in route table sunusroute.
                      ip rule add from 192.168.1.169 table sunusroute
                      
                * check if those are valid by:
                      
                      ip rule show
                      >> 0:	from all lookup local
                      >> 32761:	from 192.168.1.169 lookup sunusroute
                      >> many-more-lines-of-other-rules
                      ip route show table sunusroute
                      >> default via 123.150.108.1 dev ppp0
                      ip route flush cache
                      
                * the last command `ip route flush cache` is just a precaution, in case the old rules in cache might do something nasty.
                
                * we are done in this step.
                
         3 . Also, Since the Route's default gateway isn't 123.150.232.1, so it's a must to set packet's **source address** to 123.150.232.74. so here we will do a **SNAT** magic.
         * we are officially meet the iptables here, the firewall of the linux, a great tool for many other usages as well.
                 
           * the iptables consists by some tables, and those tables has some chains. the packet need to go all the way from the very first chain to the very last one. so that this packet can be send/receive correctly. during the packet's travel in those tables and chains, it might be modify, accept, drop or reject, we can even add marks to those packets so that we can debug them.
           * here is a brief image of how a packets goes.
             
           ![iptables packetes traversal path](/images/iptables_traverse.jpg "iptables_traverse")
                 
           * obviously, what we want the route to do is:
           
           **forward the packets from 192.168.1.169 to interface ppp0 with the right gateway 123.150.231.1**
           
           * follow the diagram, the packets should go through the tables and chains in the order of
               
               1. [packet come in from ppp0]
               2. [raw-PREROUTING]
               3. [mangle-PREROUTING]
               4. [filter-PREROUTING]
               5. [ROUTING-DESICION]
               6. [mangle-FORWARD]
               7. [filter-FORWARD]
               8. [ROUTING-DESICION]
               9. [mangle-POSTROUTING]
              10. [nat-POSTROUTING]
              11. [packet come out from ppp0]
           
           * I once not sure/doubt about what those **ROUTING-DESICION** do, after my research, i think it's just decide what **route** to use, basically, it just look up the routing table and get a **route** to use.
           
           * so, what we need to do is, change the packets's source address right after the packet go off. that is, in the step ten.
              
              ``iptables -t nat -o ppp0 -j SNAT --to-address 123.150.232.74``
              
         4 . We're pretty much done here:)
         
         5 . Enjoy!
 
# More useful resources.
##i read a lot of them to make this work, i think you should do that, too. if you **relly** want to fully utilize your network. 

1. the **iptable-tutorial** 
   * [http://www.frozentux.net/documents/iptables-tutorial/](http://www.frozentux.net/documents/iptables-tutorial)
     * pretty much every chapter is worthy reading :)
     
2. the awesome and notable **Linux Advanced Routing & Traffic Control**, aka 'lartc' 
   * [http://lartc.org](http://lartc.org)
     * especially chapter 4 and 11 are much involved in this post.
3. **much more** you will find in those two above.

4. 1,2 also have Chinese version, thank for those guy who do the translation work!

# PS
## since i now got kinda *experience* of doing those stuffs, you are welcome to leave a message or just email me about what you think or what you want to do. i will try to help you if i can.

## ANY questions and discussion are welcomed, too.
