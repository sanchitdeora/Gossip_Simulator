# Gossip-Simulator
Distributed Operating System - Project 2

## Team Members:

Sanchit Deora (8909 – 4939)  
Rohit Devulapalli (4787 – 4434)


## Problem Definiton

Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.

## What is working (Algorithms and Topologies included):

### Gossip:

* Full
* Line
* Random2D
* 3D Torus
* Honeycomb
* Random Honeycomb

### Push-sum:

* Full
* Line
* Random2D
* 3D Torus
* Honeycomb
* Random Honeycomb

### Instructions to run the code:

#### Running Gossip:

```
$ mix run proj2.exs 100 full gossip
$ mix run proj2.exs 100 line gossip
$ mix run proj2.exs 100 rand2D gossip
$ mix run proj2.exs 100 torus3D gossip
$ mix run proj2.exs 100 honeycomb gossip
$ mix run proj2.exs 100 randhoneycomb gossip
```

#### Running PushSum

```
$ mix run proj2.exs 100 full pushsum
$ mix run proj2.exs 100 line pushsum
$ mix run proj2.exs 100 rand2D pushsum
$ mix run proj2.exs 100 torus3D pushsum
$ mix run proj2.exs 100 honeycomb pushsum
$ mix run proj2.exs 100 randhoneycomb pushsum
```

#### Running Gossip:

```
$ mix run proj2_bonus.exs 100 full gossip
$ mix run proj2_bonus.exs 100 line gossip
$ mix run proj2_bonus.exs 100 rand2D gossip
$ mix run proj2_bonus.exs 100 torus3D gossip
$ mix run proj2_bonus.exs 100 honeycomb gossip
$ mix run proj2_bonus.exs 100 randhoneycomb gossip
```

#### Running PushSum

```
$ mix run proj2_bonus.exs 100 full pushsum
$ mix run proj2_bonus.exs 100 line pushsum
$ mix run proj2_bonus.exs 100 rand2D pushsum
$ mix run proj2_bonus.exs 100 torus3D pushsum
$ mix run proj2_bonus.exs 100 honeycomb pushsum
$ mix run proj2_bonus.exs 100 randhoneycomb pushsum
```

### Maximum Nodes:

#### Gossip Protocol:

```
Topology		Maximum Nodes	Convergence Time
Full				5000		194237
Line				5000		170359
Random 2D			5000		337297
3D Torus			5000		143422
Honeycomb			5000		160756
Random Honeycomb	        5000		188406
```

#### Push Sum:

```
Topology		Maximum Nodes	Convergence Time
Full				5000		217852
Line				700		1059579
Random 2D			5000		240658
3D Torus			5000		172610
Honeycomb			2000		515266
Random Honeycomb	        5000	        61766
```




