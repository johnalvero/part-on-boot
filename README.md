### Procedure

1. Clone this repo
1. Modify scheme.txt to reflect your own partition scheme
1. Run the creation script
```
create-userdata-sh
```

The last command will zip and base64 encode the scheme.txt and part.sh files. It will then generate a new userdata based on a template in user-data.tmpl. The output of the last command can then be used as AWS user-data script to start a new instance.
