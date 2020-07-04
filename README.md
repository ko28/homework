# homework

Some of my typed up homework solutions and projects from courses taken at UW-Madison. 

Some solutions may be incomplete or incorrect, read at your own risk. 

For future me, [here](https://stackoverflow.com/questions/17371150/moving-git-repository-content-to-another-repository-preserving-history)
is how to move another repo into this repo:
```
cd repo2
git checkout master
git remote add r1remote **url-of-repo1**
git fetch r1remote
git merge r1remote/master --allow-unrelated-histories
git remote rm r1remote
```

