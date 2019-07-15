# Current Status of Dissertation Project

I am struggling to replicate Naama's results from her paper. However, my analysis pipeline does correctly replicate her results with her own data
	- to do here: really run Naama's data through the _CS versions of my scripts, since they're technically different. Be honest with yourself._

**my qualifying exam is coming up on August 14th, and here is my current plan for the form of my dissertation proposal:**

My two main goals are: 
- to demphasize the idea that there are instantaneous shifts in population activity that link directly to intermittent control theory
- search out additional ways to potentially identify state shift structure in activity without assuming a discrete process.


1. There are transitions between neural population states, over time, in movement areas of the brain, surrounding movement. 

2. There is evidence for neural transitions between states within movements, not just between preparation and movement.

3. I think that there are distinct transitions between accelerative and decelerative segments of movement

4. I want to use a specific method to identify these transition points, and use additional methods to analyse those transitions.



### Update from 7/1/19:

I'm having significant issues still replication results. I pulled in a previously gathered dataset from the same monkey, doing a center-out task. The results of this analysis left a lot to be desired, with similar states to other Breaux datasets.

Last week, I tried to sort another day of data, 190226. Unfortunately, there's something wrong with my CUDA install or something, and it can't sort the entire file; I need to troubleshoot that.

Right now, I'm trying to make sure that the code I run on Naama's paper data (which replicates, and works), is the same code that's running on my own data. They're different scripts, so it's _possible_ that something in the scripts are ruining results. That would actually be nice, but god who knows.

### Update from 7/8/19

Good news! Turns out that I was mismatching the kinematic timing for Breaux's old dataset. After correctly aligning everything, the results looked really good! I'm taking data from 180323, which Vassilis had sorted for Wei a while ago. With luck, I'll be able to show that this replicates Naama's findings, and I can present this as *something* promising at my qual. Whoo!

### Update from 7/10/19

I'm turning my focus to my specific aims, and writing my proposal in general. Dalton got me kind of freaked out, since he said that he has started writing his up already. I want to start writing, but here's what I think is missing so far:

- I need a continuous model to run on my data.
	- jPCA? GPFA?
- I need a way to compare that continuous model to my data.
	- It would be ideal to do something a little more sophisticated than R^2, but I don't have any ideas.
- I need to think a little more about the methods that I'm going to use to investigate transitions
	- I like Naama's idea of zooming in on PCA space and looking for deviations there.
- How am I going to incorporate the human project into my dissertation? Is it cheap to just throw in a human data comparison for imagined reaches?

What are my specific aims after reorganizing my project around addressing these issues? Do I need to reorganize them? Or, just recontextualize them? I think I probably just need to recontextualize them.

### Update from 7/15/19

I am still struggling with a way to incorporate the controls that have been asked for into my narrative. I feel like the HMM is the center of my project, but I don't want it to be.

What is the problem that I'm trying to solve? Could I frame everything in terms of the "toolset" argument? What would that look like?

The human body creates infinite permutations of movements with a limited number of areas and neurons. Primate motor cortex plays an integral role in structuring motor commands, and many rules have been devised about how limited areas can produce complex movement. As early as population coding, all the way up to modern dynamical systems theory, researchers are working hard to identify the tools that motor cortex uses to create movement. There is growing evidence to suggest that primary motor cortex in particular is using a limited set of related activity patterns, strung together to generate behavior. In some instances, researchers discuss these activity patterns as related rotational dynamics, whereas other refer to similar neural states, between which the brain alternates. Regardless, there is significant evidence to suggest that motor cortex's activity must transition between these sets of activity patterns. On the most basic level, transitions can be identified between preparation and execution of movement.

I plan to use an analysis method that assumes discrete transitions between neural states, with the acknowledgement that transitions are most likely not instantaneous, and proving such would prove fruitless. Instead, I will use this analysis method (which primarily utilises a markovian process) to determine points of population state transition during movement. I will then use different methods such as basic PCA analysis to examine population activity at proposed transition points to characterize the speed, nature, and magnitude of those changes compared to intra-state activity.

I plan to verify the fit and performance of my "discrete" models by comparing it with the performance of modern continuous models, such as jPCA or LFADS.
