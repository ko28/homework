# homework

Some of my typed up homework solutions and projects from courses taken at UW-Madison. 

Some solutions may be incomplete or incorrect, read at your own risk. 

For future me, [here](https://stackoverflow.com/questions/17371150/moving-git-repository-content-to-another-repository-preserving-history)
is how to move another repo into this repo:
```
cd homework
git checkout master
git remote add new-repo **url-of-new-repo**
git fetch new-repo
git merge new-repo/master --allow-unrelated-histories
git remote rm new-repo
```

