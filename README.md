# Check AWS Inspector Test #

Used to provision the required resources and a github action for testing [check-aws-inspector](https://github.com/ecperth/check-aws-inspector)

### Usage ###
```
git clone https://github.com/ecperth/check-aws-inspector-test
```

Then update main.tf and configure aws credentials as per [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

Then 
```
terraform init
terraform apply
```

This should provision all the resources for you to test the check-aws-inspector github action. You can then fork or create a new repo and push the code to github in order to run the check-aws-inspector-test action.

Once you have created the github repo you need to add a couple of [repository variables](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository). **AWS_ACCOUNT_ID** and **AWS_REGION**.

Then you can run the Push + Check Scan action.

![gh action form](./gh-action-form.png?raw=true "Github action form")

**base-image:** [string] The image tag you want to scan from public docker hub registry.

**tag:** [string] The image tag you want to attach to the image built and pushed to ecr.

The remaining fields map to the corresponding fields mentioned in https://github.com/ecperth/check-aws-inspector