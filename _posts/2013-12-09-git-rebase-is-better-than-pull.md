---
layout: post
title: "Git: rebase is better than pull"
description: "why we should use rebase more often, 为什么要多使用rebase"
category: ""
tags: ['Linux', 'Git']
comments: true
---

##热身
该Blog起源于最近和朋友讨论关于Git的一些特性, 在讨论中发现他对Git多人协作当中的模型并不是很熟悉.

如果你是Git的初学者, 建议先去[Git-Learn-Branching][GLB] 玩玩前2~3个Level, 了解下**rebase**, **pull**

如果该项目*只有*你一人开发, 那么git的pull是不会有问题的.

##背景介绍

当前, 我们有2位开发者: *sunus*, *vivian*
他们想进行pari programming一个项目. 并且该项目是由*god*发起的,已有2次commits.
他们会将对新的代码提交到**dev**分支上, 之后由*god*将新代码合并到稳定分支**master**

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/awesome-project] (master ✔)
[22:36]:cat git.c
#include <stdio.h>

int main()
{
        printf("Hello Git!");
        return 0;
}
sunus@mbp~[/private/var/tmp/git-pull/awesome-project] (master ✔)
[22:36]:git log
commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE

commit d22bf163d093afb494ad619d8964572e55c73167
Author: god <god@mbp>
Date:   Mon Dec 9 22:11:40 2013 +0800

    write first lines of codes

commit 45f2016a51ce7b8317e074a961647c091a50cd94
Author: sunus <god@mbp>
Date:   Mon Dec 9 22:04:41 2013 +0800

    add first file

sunus@mbp~[/private/var/tmp/git-pull/awesome-project] (master ✔)
[22:48]:git branch
dev
* master
{% endhighlight %}

PS, 在命令行的末端会显示我们当前所在的branch, 比如在这儿是master.

PSS, branch之后的符号是表示当前的branch是否有被修改但是还没commit的内容: ✔表示没有, ⚡表示有.

现在, *sunus*, *vivian* 他们分别将项目clone到他们的本地.

{% highlight bash %}
[22:52]:echo "I am sunus:)"
I am sunus:)
sunus@mbp~[/private/var/tmp/git-pull]
[22:52]:git clone awesome-project sunus
Cloning into 'sunus'...
done.
Checking connectivity... done
sunus@mbp~[/private/var/tmp/git-pull]
[22:52]:cd sunus
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[22:52]:ls
git.c
{% endhighlight %}

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull]
[22:54]:echo "I am vivian ^^"
I am vivian ^^
sunus@mbp~[/private/var/tmp/git-pull]
[22:55]:git clone awesome-project vivian
Cloning into 'vivian'...
done.
Checking connectivity... done
sunus@mbp~[/private/var/tmp/git-pull]
[22:55]:cd vivian
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ✔)
[22:55]:ls
git.c
{% endhighlight %}

好了, 现在开始Pair Progamming:)


####*sunus* 写了一些代码, 并且在**本地分支**有2个commits.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:07]:git diff
diff --git a/git.c b/git.c
index 7d26397..127e99a 100644
--- a/git.c
+++ b/git.c
@@ -2,6 +2,8 @@

 int main()
 {
+        void *p;
         printf("Hello Git!");
+        printf("I am sunus and I am here with vivian");
         return 0;
 }

sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:07]:git add git.c
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:09]:git commit -m 'I add a intro'
[master 1c0b75b] I add a intro
 1 file changed, 1 insertion(+)
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[23:09]:
{% endhighlight %}

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:13]:git diff
diff --git a/git.c b/git.c
index 668a8f3..50aae80 100644
--- a/git.c
+++ b/git.c
@@ -1,8 +1,16 @@
 #include <stdio.h>

+void *magic()
+{
+        return (void *)magic;
+}
+
 int main()
 {
+        void *p;
         printf("Hello Git!");
-        printf("I am sunus and I am here with vivian");
+        printf("I am sunus and I am here with vivian\n");
+        p = magic();
+        printf("I will show you a magic: %p", p);
         return 0;
 }
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:13]:git add git.c
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:13]:git commit -m 'show you a magic'
[master 6df90b8] show you a magic
 1 file changed, 9 insertions(+), 1 deletion(-)
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
{% endhighlight %}

以下是*sunus*的log

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[23:19]:git log
commit 6df90b8dc07988fb9590100338af6897d119ca1b
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:14:07 2013 +0800

    show you a magic

commit 1c0b75b60d68ccc58eca5519f7fd15912277be84
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:09:41 2013 +0800

    I add a intro

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE

commit d22bf163d093afb494ad619d8964572e55c73167
Author: god <god@mbp>
Date:   Mon Dec 9 22:11:40 2013 +0800

    write first lines of codes

commit 45f2016a51ce7b8317e074a961647c091a50cd94
Author: god <god@mbp>
Date:   Mon Dec 9 22:04:41 2013 +0800

    add first file
{% endhighlight %}


####*vivian* 也写了一些代码, 并且在**本地分支**有1个commit

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ⚡)
[23:25]:git diff
diff --git a/git.c b/git.c
index 7d26397..003e1ee 100644
--- a/git.c
+++ b/git.c
@@ -3,5 +3,6 @@
 int main()
 {
         printf("Hello Git!");
+        printf("I am vivian, I am new to Programming in C:<");
         return 0;
 }
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ⚡)
[23:25]:git add git.c
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ⚡)
[23:25]:git commit -m 'vivian committttt^^'
[master 1838ec2] vivian committttt^^
 1 file changed, 1 insertion(+)
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ✔)
[23:25]:git log
commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE

commit d22bf163d093afb494ad619d8964572e55c73167
Author: god <god@mbp>
Date:   Mon Dec 9 22:11:40 2013 +0800

    write first lines of codes

commit 45f2016a51ce7b8317e074a961647c091a50cd94
Author: god <god@mbp>
Date:   Mon Dec 9 22:04:41 2013 +0800

    add first file
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ✔)
[23:25]:
{% endhighlight %}

####现在是什么情况?

*sunus*, *vivian*都在本地基于**origin上的远程分支**编写了自己的代码.
但是他们**不知道对方**干了什么. 于是, 他们需要**合并两人的修改, 并且将更新提交到远程dev分支上**

*vivian*动作比较快, 什么也没想就push了.
{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/vivian] (master ✔)
[23:34]:git push -u origin master:dev
Counting objects: 5, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 343 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To /private/var/tmp/git-pull/awesome-project
   163a6d7..1838ec2  master -> dev
Branch master set up to track remote branch dev from origin.
{% endhighlight %}

这看起来是成功了, *god*也能够看到*vivian*的改动:)

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/awesome-project] (dev ✔)
[23:35]:cat git.c
#include <stdio.h>

int main()
{
        printf("Hello Git!");
        printf("I am vivian, I am new to Programming in C:<");
        return 0;
}
sunus@mbp~[/private/var/tmp/git-pull/awesome-project] (dev ✔)
[23:35]:git log
commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE
{% endhighlight %}


接下来看*以前的sunus*会怎么做(他要倒霉了)

##PULL

```git pull```该是git初学者们常用的一个操作, 他们一般认为该操作知识将**本地版本库**与**远程的版本库**同步更新.

但是并不知道这**背后实际发生了什么**, 这也是为什么pull在大多数情况下,单个/少数开发者合作能够work, 但是在实际和多人协作中会造成问题的原因.

下面是简单的workflow:

首先, *sunus*并不知道origin是否有改动, 他也是直接push.

{% highlight bash %}
[23:42]:git push -u origin master:dev
To /private/var/tmp/git-pull/awesome-project
 ! [rejected]        master -> dev (fetch first)
error: failed to push some refs to '/private/var/tmp/git-pull/awesome-project'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first merge the remote changes (e.g.,
hint: 'git pull') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
{% endhighlight %}

很明显, push不成功, 因为*vivian*抢先一步对远程版本库做了修改. 所以, sunus看到了要先做```git pull```的hint.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[23:47]:git pull origin dev
From /private/var/tmp/git-pull/awesome-project
 * branch            dev        -> FETCH_HEAD
Auto-merging git.c
CONFLICT (content): Merge conflict in git.c
Automatic merge failed; fix conflicts and then commit the result.
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ⚡)
[23:48]:cat git.c
#include <stdio.h>

void *magic()
{
        return (void *)magic;
}

int main()
{
        void *p;
        printf("Hello Git!");
<<<<<<< HEAD
        printf("I am sunus and I am here with vivian\n");
        p = magic();
        printf("I will show you a magic: %p", p);
=======
        printf("I am vivian, I am new to Programming in C:<");
>>>>>>> 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
        return 0;
}
{% endhighlight %}

好了, 接下来还是蛮常见的事情, *sunus*, *vivian*都对相关的代码做了修改, 现在有冲突了, sunus需要手动解决.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[23:52]:cat git.c
#include <stdio.h>

void *magic()
{
        return (void *)magic;
}

int main()
{
        void *p;
        printf("Hello Git!");
        printf("I am sunus and I am here with vivian\n");
        p = magic();
        printf("I will show you a magic: %p", p);
        printf("I am vivian, I am new to Programming in C:<");
        return 0;
}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[23:52]:git log
commit 135990d6a92554009966c7b88133501adba767f2
Merge: 6df90b8 1838ec2
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:51:59 2013 +0800

    pull and resolved a conflict

commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^
{% endhighlight %}


ok,在这儿, *sunus*看了把手上的工作也做完了, 可以把代码push交到远程origin了.(会发生什么事呢?)

我们先比较一下当前*sunus*, *vivian*两人在本地的git仓库情况:

*vivivan*

![vivian-after-push.png](/images/git-pull-and-rebase/vivian-after-push.png)

*sunus*

![sunus-before-push.png](/images/git-pull-and-rebase/sunus-before-push.png)

*sunus*开始push.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-pull/sunus] (master ✔)
[0:12]:git push -u origin master:dev
Counting objects: 13, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (6/6), done.
Writing objects: 100% (9/9), 903 bytes | 0 bytes/s, done.
Total 9 (delta 2), reused 0 (delta 0)
To /private/var/tmp/git-pull/awesome-project
   1838ec2..135990d  master -> dev
Branch master set up to track remote branch dev from origin.
{% endhighlight %}

push成功了, 接下来, 看看当前*sunus*, *vivian*, *god* 本地分支的情况:

*sunus*

![sunus-after-push.png](/images/git-pull-and-rebase/sunus-after-push.png)

*vivian*

![vivian-after-sunus-push.png](/images/git-pull-and-rebase/vivian-after-sunus-push.png)

*god*

![god-after-sunus-push.png](/images/git-pull-and-rebase/god-after-sunus-push.png)

看起来好似没有问题, 不就是有个环吗?

但是, 尝试下```git log -p``` 会发现, 这儿*根本没有* *sunus* push之后的详细日志, 不可思议吧?!

也就是说, 除了*sunus*, 别人并不知道*sunus*和*vivian*他们俩的代码, 最终是如何*合并*的.

除非对单个commit依次进行**diff**

##Fetch + Rebase

让我们再来看看另一种做法, 也是我比较推荐的. 使用fetch 然后再进行rebase.

fetch: 只把origin源改动下载到本地, 但是并不进行合并.

rebase: 把当前的branch放到另一个branch的顶端, 体现的形式是开发的过程是**线性**的, 而不是一个环(pull/merge)

我们回到刚才*sunus*的情形: *vivian*已经push了代码.

这次, *sunus*使用fetch

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] (master ⚡)
[11:15]:git fetch origin
remote: Counting objects: 5, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
From ../awesome-project
 * [new branch]      dev        -> origin/dev
 * [new branch]      master     -> origin/master
{% endhighlight %}

我们把新的改动下载后, 新的分支有:

1. **origin/dev** 该分支有*vivian*的新改动
2. **origin/master** 远程origin的**master**分支, 在这不需要理会.

接下来, 我们要做的事情是, 把我们的改动放在**origin/dev**分支的最顶部, 即紧接着*vivian*的改动. 这样看起来像一个人写的代码一样.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-fetch-rebas/sunus] (master ⚡)
[11:16]:git rebase origin/dev
First, rewinding head to replay your work on top of it...
Applying: I add a intro
Using index info to reconstruct a base tree...
M	git.c
Falling back to patching base and 3-way merge...
Auto-merging git.c
CONFLICT (content): Merge conflict in git.c
Failed to merge in the changes.
Patch failed at 0001 I add a intro
The copy of the patch that failed is found in:
   /private/var/tmp/git-fetch-rebase/sunus/.git/rebase-apply/patch

When you have resolved this problem, run "git rebase --continue".
If you prefer to skip this patch, run "git rebase --skip" instead.
To check out the original branch and stop rebasing, run "git rebase --abort".

sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] ((no ⚡)
[11:16]:git mergetool
Merging:
git.c

Normal merge conflict for 'git.c':
  {local}: modified file
  {remote}: modified file
Hit return to start merge resolution tool (vimdiff):
4 files to edit
{% endhighlight %}

ok, 在这儿会遇到一次**merge**的冲突, 我们使用**mergetool**解决. 然后继续rebase

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] ((no ⚡)
[11:18]:git rebase --continue
Applying: I add a intro
Applying: show you a magic
Using index info to reconstruct a base tree...
M	git.c
Falling back to patching base and 3-way merge...
Auto-merging git.c
CONFLICT (content): Merge conflict in git.c
Failed to merge in the changes.
Patch failed at 0002 show you a magic
The copy of the patch that failed is found in:
   /private/var/tmp/git-fetch-rebase/sunus/.git/rebase-apply/patch

When you have resolved this problem, run "git rebase --continue".
If you prefer to skip this patch, run "git rebase --skip" instead.
To check out the original branch and stop rebasing, run "git rebase --abort".

sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] ((no ⚡)
[11:18]:git mergetool
Merging:
git.c

Normal merge conflict for 'git.c':
  {local}: modified file
  {remote}: modified file
Hit return to start merge resolution tool (vimdiff):
4 files to edit
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] ((no ⚡)
[11:19]:cat git.c
#include <stdio.h>

void *magic()
{
        return (void *)magic;
}

int main()
{
        void *p;
        printf("Hello Git!");
        printf("I am sunus and I am here with vivian\n");
        p = magic();
        printf("I will show you a magic: %p", p);
        printf("I am vivian, I am new to Programming in C:<");
        return 0;
}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] ((no ⚡)
[11:19]:git rebase --continue
Applying: show you a magic
{% endhighlight %}

ok, rebase完成, 可以看到最后*sunus*的2个commit: 5580/8318 是在当前log的最顶端.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] (master ✔)
[11:19]:git log
commit 5580978c60d157da68816644aba7afecd328a4be
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:14:07 2013 +0800

    show you a magic

commit 8318c499e6d5c4d9fd9ba46c19994c326a6cb1c5
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:09:41 2013 +0800

    I add a intro

commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE

{% endhighlight %}

接下来, 把我们本地的变动提交到远程仓库.

{% highlight bash %}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/sunus] (master ✔)
[11:32]:git push -u origin master:dev
Counting objects: 8, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (6/6), 663 bytes | 0 bytes/s, done.
Total 6 (delta 1), reused 0 (delta 0)
To ../awesome-project
   1838ec2..5580978  master -> dev
Branch master set up to track remote branch dev from origin.
{% endhighlight %}

我们看看*sunus*, *god*当前的历史情况.

*sunus*

![sunus-push-after-rebase.png](/images/git-pull-and-rebase/sunus-push-after-rebase.png)

*god*

![god-after-sunus-rebase-push.png](/images/git-pull-and-rebase/god-after-sunus-rebase-push.png)

ok, 看起来很不错!

然后看看*vivian*需要做什么获取最新的代码

{% highlight bash%}
sunus@mbp~[/private/var/tmp/git-fetch-rebase/vivian] (master ✔)
[11:56]:git fetch
remote: Counting objects: 8, done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 1), reused 0 (delta 0)
Unpacking objects: 100% (6/6), done.
From ../awesome-project
 * [new branch]      dev        -> origin/dev
 * [new branch]      master     -> origin/master
sunus@mbp~[/private/var/tmp/git-fetch-rebase/vivian] (master ✔)
[11:57]:git diff master origin/dev
diff --git a/git.c b/git.c
index 003e1ee..0187070 100644
--- a/git.c
+++ b/git.c
@@ -1,8 +1,17 @@
 #include <stdio.h>

+void *magic()
+{
+        return (void *)magic;
+}
+
 int main()
 {
+        void *p;
         printf("Hello Git!");
+        printf("I am sunus and I am here with vivian\n");
+        p = magic();
+        printf("I will show you a magic: %p", p);
         printf("I am vivian, I am new to Programming in C:<");
         return 0;
 }
sunus@mbp~[/private/var/tmp/git-fetch-rebase/vivian] (master ✔)
[11:57]:git log
commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE

sunus@mbp~[/private/var/tmp/git-fetch-rebase/vivian] (master ✔)
[11:57]:git merge origin/dev
Updating 1838ec2..5580978
Fast-forward
 git.c | 9 +++++++++
 1 file changed, 9 insertions(+)

sunus@mbp~[/private/var/tmp/git-fetch-rebase-bak/vivian] (master ✔)
[11:58]:git log
commit 5580978c60d157da68816644aba7afecd328a4be
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:14:07 2013 +0800

    show you a magic

commit 8318c499e6d5c4d9fd9ba46c19994c326a6cb1c5
Author: sunus <sunuslee@gmail.com>
Date:   Mon Dec 9 23:09:41 2013 +0800

    I add a intro

commit 1838ec2b16be49b5aa084eb463e8d03e3b1f47de
Author: vivian <vivian@gmail.com>
Date:   Mon Dec 9 23:25:34 2013 +0800

    vivian committttt^^

commit 163a6d700226b780b7852a79fe1370a6d38c819a
Author: god <god@mbp>
Date:   Mon Dec 9 22:13:15 2013 +0800

    remove FILE
{% endhighlight%}

嗯, *vivian*这边也没什么问题, 也同步了本地的版本库.

最后看看她本地的历史:

![vivian-after-sunus-rebase](/images/git-pull-and-rebase/vivian-after-sunus-rebase-push.png)

嗯, 看起来好极了~

##总结

* 如果你只是一个人在开发一个项目, 并且在第三方托管(比如github) 那么不管是使用pull还是/fetch rebase都不会有太大问题, 而且pull还是更方便
    * github的**pull request**也是通过将他人的改动, 放到当前历史的最顶端来解决这个问题.

* 如果是多人合作的话, 大部分情况下pull是不会有问题的, 但是会照成合并之后的版本日志混乱, 开发的过程混乱.(因为版本的修改记录是一个环)

* 所以最好还是, 多fetch, 多rebase.这样, 版本的记录是能够保持**线性**的, 并且每次改动都能在日志里看得很明白.


[GLB]: http://pcottle.github.io/learnGitBranching/?demo

