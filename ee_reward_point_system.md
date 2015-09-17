---
layout: default
title: Reward Point System
chapter: 12
meta-description: Notes on Enterprise Reward Point System
---

# Reward Point System

Exam proportion: ~3%.

Reward points can be awarded for a wide variety of transaction and customer activities. They're a great way of gaining repeat customers but also for extending customer lifetime value.

They work by rewarding a customer for doing certain actions, like signing up to the newsletter, making a purchase etc. Two important thing to setup for a store is:

1. Points to Currency, this determines how much currency is discounted for X amount of points at the checkout.
2. Currency to points, this determines how many points are added for X order value.

These are configured in `Customers > Reward Exchange Rates`.

The actions, rules and e-mails for the store are configured in `System > Configuration > Customers > Reward Points`

## Describe how to customize, extend, and troubleshoot the Enterprise Edition reward point system:

### How do the features offered by the reward point system hook into other Magento modules?

Config.xml shows that the module doesn't rewrite **any** models, helpers or blocks. The main way it interacts with other models is via the events the other modules dispatch, such as:

1. __newsletter\_subscriber\_save\_commit\_after__
2. __paypal\_prepare\_line\_items__
3. __sales\_order\_save\_after__
4. __sales\_quote\_collect\_totals\_before__
5. __sales\_quote\_merge\_after__
6. __sales\_order\_load\_after__
7. __sales\_order\_invoice\_register__
8. __sales\_order\_invoice\_pay__
9. __sales\_order\_invoice\_save\_commit\_after__
10. __sales\_order\_creditmemo\_refund__
11. __sales\_order\_creditmemo\_save\_after__
12. __sales\_model\_service\_quote\_submit\_before__
13. __sales\_model\_service\_quote\_submit\_failure__
14. __checkout\_type\_multishipping\_create\_orders\_single__
15. __checkout\_multishipping\_refund\_all__

The module adds various attributes to `sales_flat_order`, `sales_flat_quote` and `sales_flat_creditmemo` tables in order to track and trace the rewards points allocated,
redeemed and refunded, these fields are copied to the orders with the fieldsets XML

```xml
<fieldsets>
    <sales_convert_quote_address>
        <reward_points_balance>
            <to_order>*</to_order>
        </reward_points_balance>
        <reward_currency_amount>
            <to_order>*</to_order>
        </reward_currency_amount>
        <base_reward_currency_amount>
            <to_order>*</to_order>
        </base_reward_currency_amount>
    </sales_convert_quote_address>
</fieldsets>
```

It also adds a new totals model

```xml
 <quote>
    <totals>
        <reward>
            <class>enterprise_reward/total_quote_reward</class>
            <after>weee,discount,tax,tax_subtotal,grand_total</after>
            <before>giftcardaccount,customerbalance</before>
            <renderer>enterprise_reward/checkout_total</renderer>
        </reward>
    </totals>
</quote>
```



#### Extending the module.

The main class to extend would be `Enterprise_Reward_Model_Reward` and add additional functionality"

```xml
<config>
    <global>
        <models>
            <enterprise_reward>
                <rewrite>
                    <reward>Namespace_Namespace_Model_Reward</reward>
                </rewrite>
            </enterprise_reward>
        </models>
    </global>
</config>
```

You could also override `Enterprise_Reward_Model_Observer` in a similar way if you wanted to alter how a specific reward point are calculated for an action.

### Under which conditions may reward points be assigned?

Reward points are assigned for specific actions as mentioned above. By default they include:

1. Purchase
2. Registration
3. Newsletter Signup
4. Converting Invitation to Customer
    1. Converting Invitation to Order
5. Review Submission
6. New Tag Submission

### Which steps are required to add new custom options to assign reward points?

Extending the module would be fairly easy but unfortunately it's also not as nice as it could be.

1. The best uncoupled method would be to listen to another event but you could also override a class which has the action you want to reward. This is where you'll reference your action via your `ACTION_ID` which you'll create shortly.

```php
<?php
    function someObserverCall($observer) {
        //Some logic to determine if the action is worth a reward
        //...
        $reward = Mage::getModel('enterprise_reward/reward')
                ->setSomeDataAsImVarien('some data')
                ->setStore($subscriber->getStoreId())
                ->setAction(Namespace_Namespace_Model_Reward::MY_ACTION_ID)
                ->setActionEntity($theEntityToReward)
                ->updateRewardPoints();
    }
?>
```

2. You would add you options to your system.xml using the same hierarchy as this modules system.xml so your options appear in the same tab and group as this module.
3. You would need to create a new `ACTION_ID` (12 actions below map to the 12 actions in the admin (except the admin action), events have more so they can deal with refunds etc)
This is where the icky bit starts. The `ACTION_ID` is an INT (below) and it's value is also used as an index into the `self::$_actionModelClasses` array which maps to the actions model factory name. So you'll
need to add your ACTION_ID to that array and move to 4 by extending Enterprise\_Reward\_Model\_Reward.
4. You'll now need to either use, extend or code a new Action (all actions are parents of `Enterprise_Reward_Model_Action_Abstract`), making sure to add the actions
model factory name to your `ACTION_ID` entry in the `self::$_actionModelClasses` array. It is these action objects which define the logic of that action (can it be applied, what the entity is)
as well as the amount of points for that action.
5. You'll then need to go back to the observer / class your overrode in (1) and tell it the ACTION_ID to use.
6. You should now be listening to an event / method and calculating rewards based on your defined ACTION_ID.

```php
<?php
    /* Enterprise_Reward_Model_Reward */
    const REWARD_ACTION_ADMIN               = 0;
    const REWARD_ACTION_ORDER               = 1;
    const REWARD_ACTION_REGISTER            = 2;
    const REWARD_ACTION_NEWSLETTER          = 3;
    const REWARD_ACTION_INVITATION_CUSTOMER = 4;
    const REWARD_ACTION_INVITATION_ORDER    = 5;
    const REWARD_ACTION_REVIEW              = 6;
    const REWARD_ACTION_TAG                 = 7;
    const REWARD_ACTION_ORDER_EXTRA         = 8;
    const REWARD_ACTION_CREDITMEMO          = 9;
    const REWARD_ACTION_SALESRULE           = 10;
    const REWARD_ACTION_REVERT              = 11;
    const REWARD_ACTION_CREDITMEMO_VOID     = 12;

    //...

    protected function _construct()
        {
            parent::_construct();
            $this->_init('enterprise_reward/reward');
            self::$_actionModelClasses = self::$_actionModelClasses + array(
                self::REWARD_ACTION_ADMIN               => 'enterprise_reward/action_admin',
                self::REWARD_ACTION_ORDER               => 'enterprise_reward/action_order',
                self::REWARD_ACTION_REGISTER            => 'enterprise_reward/action_register',
                self::REWARD_ACTION_NEWSLETTER          => 'enterprise_reward/action_newsletter',
                self::REWARD_ACTION_INVITATION_CUSTOMER => 'enterprise_reward/action_invitationCustomer',
                self::REWARD_ACTION_INVITATION_ORDER    => 'enterprise_reward/action_invitationOrder',
                self::REWARD_ACTION_REVIEW              => 'enterprise_reward/action_review',
                self::REWARD_ACTION_TAG                 => 'enterprise_reward/action_tag',
                self::REWARD_ACTION_ORDER_EXTRA         => 'enterprise_reward/action_orderExtra',
                self::REWARD_ACTION_CREDITMEMO          => 'enterprise_reward/action_creditmemo',
                self::REWARD_ACTION_SALESRULE           => 'enterprise_reward/action_salesrule',
                self::REWARD_ACTION_REVERT              => 'enterprise_reward/action_orderRevert',
                self::REWARD_ACTION_CREDITMEMO_VOID     => 'enterprise_reward/action_creditmemoVoid'
            );
        }
?>
```



