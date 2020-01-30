# Current Status of Dissertation Project

### Update from 6/??/19:

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

### Update from 7/19/19

Currently working on my proposal; sent out a specific aims draft to Naama and Nicho earlier today. Motivation is flagging for some reason.

Naama suggested looking at the spike sorting from the old Breaux data that works, to try and get a sense for what the *hell* is going on between our new dataset and our old dataset.

Naama also suggested looking a the distributions of preferred directions across all the datasets, to see if the overall population representation of motion (rough motion, that is) tracks over time. It's possible that Breaux's implants are failing (or at the very least, deteriorating), causing signal degredation. It's also possible that cells around his implants are dying/receding, causing a change in overall tuning. Of course, the arrays could also be receding/moving, causing a difference in the units that are picked up by each indiviual electrode. Regardless, we need to see what's going on, and why the two datasets are showing such *different* results when it's from the same goddamn monkey, excuse my french.

The worry in the back of my mind is that the data I collected is garbage.

Headpost surgery is next thursday.

### Update from 7/22/19

I have definitively transitioned into writing mode for my qualifying exam. I have a week and a half until my first practice talk in front of an audience, and I'm worried about meeting that deadline in time. I have to prepare slides in addition to preparing my thesis proposal in style of an NRSA, so that's terrifying.

I still have questions about including human work or not in my proposal (future plans, if everything goes well, sort of thing)

I should include some slides in my presentation talking about the task Dalton and I are developing together for the BMI study, in addition to flying out and learning about the system. It's possible that I could carve out my own thing there.

At this point, I have a draft of my specific aims, and I'm probably a third of the way through my written proposal. much farther to go. 

### Update from 7/23/19

I had a thought.


### Update from 8/15/19

Well, that dropped off pretty quickly; shows how hard it is to keep up on updates when things get *really* busy. But here is the short and sweet on the project.

I passed my quals, and they have major concerns about a number of things. Here are some bullets coming out of the meeting:

Follow-ups:
- Ask Matt Kaufman about generating HMM models from certain types of distributions to test the limitations of Baum-Welch algorithm on training HMMs
- Add position and posture into instantaneous linear encoding models
- Read Machine Learning textbook and take Andrew NG’s coursera course
- Draw up plan to convince Nicho that I know what I’m doing on the HMM
- run model on lots of states and stuff, they liked that
- Think about interpreting muscle data more comprehensively

There are more thoughts, but we can work from there.

### Update from 8/20/19

I need to prepare something to present at the Neuroscience retreat in a month, and then SfN after that. 
I am also prioritizing reading a machine learning textbook and writing up a paper on my method

Okay, so here's my plan for the immediate future, as determined by Nicho's advice. Find more data, analyze the heck out of that data.

Personally, there are probably a couple more things that I need to do to make my analysis pipeline a little better. Specifically, I need to fix the goddamn trial window to be cropped based on kinematic timings. This will require processing the kinematics BEFORE the HMM training, which I think I can do? We need to figure that out. Then, go from movement onset to when the hand finally slows down, because I'm inappropriately cutting off successful trials here. 

then, the next step is to find other Breaux data that's sorted, or sort it myself. this is a little more daunting task,  and I'm worried about not having Vassilis around to help me sort through the different datatsets that he's worked with, but I think I can probably figure out which datatsets have already been processed and structured, that I can just take and PUSH through my pipeline. Again, we'll see.

-----

Looks like 180313 through 180320 could be utilized for analysis. It's all center out, with only two targets. Might help us figure out the stability of models a little better.

-----------

**thoughts for the retreat:**

What if I make my retreat poster an exploration of the model itself? like, just essentially picking apart center-out datasets, running a bunch of different numbers of states, trial windows, etc, and looking at how the model performs. It's essentially an exploration of the current HMM approach, how it fares, and when it breaks down.

the 25-state result shows that it's possible for this model to potentially say something about the discrete structure of population activity.

----------------

Okay, after talking to Nicho, here's the currenty plan for analysis: analyze more of the data that I've collected myself. What's going on there? What's happening? Is my data bad or corrupt? What's up with that? Let's figure it out.

### Update from 8/27/19

My world has kind of opened up now, for better or for worse:

1. I've been tasked with writing up a short paper on my analysis method (to prove I know what I'm doing), that involves some reading and writing and learning
2. I need to put in time towards my actual dissertation project, ahead of a poster presentation at our annual neuroscience retreat in three (!) weeks
3. I'm working to create a task for our human BMI project in virtual reality
4. I was just given a potential ~first author~ project by my PI, looking at signal quality in implants over time
5. I'm in charge of organizing a monthly Motor Systems Journal Club, so I'm looking for people to present.

I'm having difficulty with spike sorting at the moment. previously, Kilosort2 was working on my machine. Now, for whatever reason, it's not longer working. I have an issue with CUDA and some sort of timeout, or whatever. It's confusing and frustrating. 


### Update from 9/6/2019

Naama has an idea to help improve my understanding of the method itself: Write my own EM and Max likelihood code. Don't use the tabular form for the HMM; start with a parametric model.

Take that Andrew Ng course

This is the time to set aside time, take a couple months and LEARN about your stuff. I most likely won't have another opportunity like this. 

What's the plan:
- Going through Andrew Ng's courses is a good idea (Do the exercises)
- Go through all the machine learning videos from Mathematical Monk (Youtube)
- Work through the texbook as well, but after the first two points
- Sit with the code from Naama's core, and rewrite it for a paramtric approach

By the end of next week, have everything sorted. Then analyze that data. If it doesn't work, go to the EMGs. Analyzing the EMGs will definitely take time.
    - Naama's core doesn't support gaussian distribution of firing, which is appropriate for the EMG data. As such, we may need to go to a different package to analyze the EMG data, which is very distressing.

Try Kevin Murphy's toolbox:
https://www.cs.ubc.ca/~murphyk/Software/HMM/hmm.html

 For comparing across tasks, you need to be very careful about the number of trials, and the variability of trials. The safest option is probably cross-training. Can you train on the center-out and subsample from the RTP? Can you identify similar movement snippets from RTP that show up center-out?

 list out the aims for the next couple weeks, share them with Nicho and Naama


**plan for retreat, which is in TWO WEEKS** I'm not longer planning to do an exploration of the model, since I don't have enough time and I need to focus. So, the plan is to make a poster which will essentially be my dissertation proposal.

**plan for sfn** this is a little more challenging. I worry that I promised too much with the abstract. So, there's something I need to do at the very least, which is to resort all the data I have. It's not enough to just do 190228 because it obviously DIDN'T WORK. So, this weekend, I need to do 2 ours of consulting work in addition to figuring out how to concatenate .ns6 files and pulling them into kilosort.

### 9/7/19

Note to self: you can merge nsx and mev files but only if they exist. i'm missing 190228am1.nev

I may be able to create nev files from boss, but i need a USB key

I could go on without the a part

I will combine nsx and nev files to the best of my ability tomorrow

offline sorter can read nsx but not nev

### 10/4/19

Well, it's been a while since I've updated this log. A lot has changed.

A number of methods have been attempted to try and analyze the February 2019 data, all of which have essentially failed. I manually sorted units in Plexon Offline Sorter, but didn't end up porting those in to matlab. I filtered and classified units sorted by Kilosort2 for 190227, and pushed those into matlab so we could analyze things, in the hope that there were just problems with 190228. However, 190227, despite having fewer units (due to more stringent classifying on my part), failed to replicate the main result from Naama's 2018 paper. 

Throughout the analysis of my own data, I was being irresponsible in my selection of states and parameters; I was essentially picking numbers of states at random. As a result, Naama and Nicho recommended stepping back and doing some log-likelihood analysis. This involved running models for numbers of states between 2 and like 24-30, including running *multiple* models for each state number as to get a better estimate. These models took **forever** to run, being multiple days on my machine.

using these log-likelihood estimations, we discovered that the LL for training data and test data display an inapropriate relationship, in that the test data shows a higher LL than the training data, which should be highly improbable. This turns out to be the case for all of our models, so we still don't know what's going on there. 

But!

this is where take a turn for the better. Ish. 

Rockstar has a single day of data in which he performed RTP and center-out reaching, in the same format as Breaux. I analyzed that data, and the results have (so far) turned out to be similar to older RS results. I also crosstrained the models, and it looks like there are some significant differences.


Talking to Naama now:

- Don't use test data LL to determine the number of states. That's improper somehow. 
- For testing optimal state number, always use the same training trialset.
- Ignore the LL of the testset. 
- The proper way to do this to 
- It's very important to think about running multiple runs.

Byron yu course would be something to look into. 

Redo plots of snippets with color-coded to task

overlap direction histograms of both tasks on top of one another

find snippets of similar trajectory, and project them on neural axes. Is there a task dimension?

take movement that is within some direction, and try to see if you see a task dimension.

Find kinematically similar movements, plot them in neural space, look for a task dimension.

Test each of your crosstrained model within its task as well. 

pick three numbers for numbers of states (have some reasoning for that number), and run with those choices. See how states are combined. 

is M1 a low-level area? is that the questions?

- is the brain different, embedding a center-out reach in a sequence of movements versus stand-alone movements? NEW TASK

### 10/14/19

Files I'm using for crosstrain kinematic comparison:

RS_HMM_analysis_16_states_11-Oct-2019crosstrain1_iter_1
RS_HMM_analysis_16_states_11-Oct-2019crosstrain2_iter_1

### 10/25/19

SfN is over, I presented my poster using RS cross-task data. It's not enough to really contribute to my dissertation (much), but it was enough for a poster and I'm happy (ish).

**next steps**

SfN was a bit of a distraction. I'm now free to focus on longer-timescale aspects of my dissertation, those being writing up the HMM explainer, exploring other switching models, and working on side projects.

I'm tentatively thinking about currently splitting my time between two different things: 

1. Learning about machine learning and models, and writing up the explainer
2. Putting in serious time towards coding up the coffee cup task for the human BMI project.

Of course, there are many other things towards which I could put my effort and time. But, I don't know what it's worth.

### 10/28/19

So, I want to try and write up this HMM treatise. I'd love to have it done in the next couple months. Unfortunately, I don't really know the best way of going about it.