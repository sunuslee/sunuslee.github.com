---
layout: post
title: "Port mapping/forwarding with IPTABLES in linux"
date: 2013-05-15 22:35
comments: true
tags: [Linux, Linux Networking]
---

# Introduction

We got a problem with the networking in my dorm and laboratory, if outgoing traffic port is 3389, the connection will be banned. so, we need to figure a way out to connect a Windows server's 3389 port, which is suck, i mean, Windows sucks. 

# Solution

I connected to one of the linux server which is in the same lan with Suck Windows Server with port, let's say 63389. the the linux with redirect the connection from 63389 to Suck Windows Server's port 3389.

this is what i did in the linux server:

        iptables -t nat -I PREROUTING 1 -p tcp -i eth0 --dport 63389 -j DNAT --to-destination SUCK-WIN-IP:3389
        iptables -t nat -A POSTROUTING -p tcp --dport 3389 -j MASQUERADE

## Note
the second target **MASQUERADE** is a really handy thing, it will be acting like SNAT most times, but it can also auto-adjust some connection problems with extra **COST** 
