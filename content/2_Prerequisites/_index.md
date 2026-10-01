---
title: "Prerequisites"
menuTitle: "Prerequisites"
weight: 20
---

Before attempting to create a stack with the templates, a few prerequisites should be checked to ensure a successful deployment:
1.  Review the key parameters for the inspection and spoke modules to understand what will be deployed based on variable values. Reference [**GWLB-in-AWS/Templates**](https://fortinetcloudcse.github.io/GWLB-in-AWS/5_templates/index.html).
2.	An AMI subscription must be active for the FortiGate license type being used in the template.
    * [**Intel BYOL Marketplace Listing**](https://aws.amazon.com/marketplace/pp/prodview-lvfwuztjwe5b2)
    * [**Intel PAYG Marketplace Listing**](https://aws.amazon.com/marketplace/pp/prodview-wory773oau6wq)
    * [**ARM BYOL Marketplace Listing**](https://aws.amazon.com/marketplace/pp/prodview-ccnrlwz74uwgk)
    * [**ARM PAYG Marketplace Listing**](https://aws.amazon.com/marketplace/pp/prodview-ohcnwr7nr2icy)

3.	The solution requires 1 to 2 EIP per FGT, depending on variable values, to be created so ensure the AWS region being used has available capacity.  Reference [**AWS Documentation**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html) for more information on EC2 service quotas and how to request increases.

4.	If BYOL licensing is to be used, ensure these licenses have been registered on the support site.
