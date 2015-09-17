---
layout: default
title: Target Rules
chapter: 11
meta-description: Notes on Enterprise Catalog Target Rules
---

# Target Rule

Exam proportion: ~3%.

Configuring the module is `Catalog > Rule-based product relations'.

## What additional possibilities does the Enterprise Target rule module provide over `Mage_CatalogRule`?

#### `Mage_CatalogRule`
The original `Mage_CatalogRule` modules applies discount rules to products. These discount promotions encourage customers to buy products.

You can select the conditions such as Category, Attribute Set and Attribute.
Then you define the actions on products which match the conditions, such as 10% discount and apply it.

#### `Enterprise_TargetRule`

`Enterprise_TargetRule` is the module behind `Rule-Based Product Relations` and adds the ability for admins to create a more relevant shopping experience for **cross selling**, **up selling** and **related products**, targetted at __specific customer segments__

Rules are in the format:

1. When these types of products are displayed (Products to match)
2. Display these products as related items (Products to display)

### Tabs

#### Rule Information

This tab contains information about the rule, such as _name, priotiry, status, active dates, customer segment_ and where 'to apply' the rules

Conditions can 'apply to'

1. Cross Sell
2. Up Sell
3. Related Products

#### Products to Match
Product Matchers can apply to

1. Attributes
2. Attribute Sets
3. Categories

#### Products to Display
Product to display can apply to

1. Attributes
2. Attribute Sets
3. Categories
4. Product Type
5. Special Price %


##How does the module store the data in the database?

Data from the admin is stored in 3 tables:

1. __enterprise\_targetrule__ This table contains general information about the Rule, such as it's name, status, active dates, serialized actions and conditions etc. It is the main table used by the `Enterprise_TargetRule_Model_Resource_Rule` model.
2. __enterprise\_targetrule\_customersegment__ This table joins the target rule with a customer segment if one has been set in the conditions. `Enterprise_TargetRule_Model_Resource_Rule` provides CRUD operations for this table.
3. __enterprise\_targetrule\_product__ This product joins the target rule with the product data and store scope. `Enterprise_TargetRule_Model_Resource_Rule` also provides CRUD operations for this table.

```xml
<rule>
    <table>enterprise_targetrule</table>
</rule>
<customersegment>
    <table>enterprise_targetrule_customersegment</table>
</customersegment>
<product>
    <table>enterprise_targetrule_product</table>
</product>
<segment>
    <table>enterprise_targetrule_customersegment</table>
</segment>
```
You'll notice __customersegment__ and __segment__ table alias' reference the same table name, I can only assume this has been left in for backward compatibility, `enterprise_targetrule/segment`
is only used in `Enterprise_TargetRule_Model_Resource_Rule_Collection` where as `enterprise_targetrule/customersegment` is used in `Enterprise_TargetRule_Model_Resource_Rule` and various upgrade scripts.

### Indexes

On top of these tables there are 7 indexes

1. __enterprise\_targetrule\_index__  Flatten target rule provides quick access to check customer group / segments. This index is managed by `Enterprise_TargetRule_Model_Index`
2. __enterprise\_targetrule\_index\_related__ Flattened target rule for faster accessing.
3. __enterprise\_targetrule\_index\_related\_product__ Provides an index for the products (FK to id on `enterprise_targetrule_index_related`)
4. __enterprise\_targetrule\_index\_upsell__ Flattened target rule for faster accessing.
5. __enterprise\_targetrule\_index\_upsell\_product__ Provides an index for the products (FK to id on `enterprise_targetrule_index_upsell`)
6. __enterprise\_targetrule\_index\_crosssell__ Flattened target rule for faster accessing.
7. __enterprise\_targetrule\_index\_crosssell\_product__ Provides an index for the products (FK to id on `enterprise_targetrule_index__crosssell`)

```xml
<index>
    <table>enterprise_targetrule_index</table>
</index>
<index_related>
    <table>enterprise_targetrule_index_related</table>
</index_related>
<index_crosssell>
    <table>enterprise_targetrule_index_crosssell</table>
</index_crosssell>
<index_upsell>
    <table>enterprise_targetrule_index_upsell</table>
</index_upsell>
<index_related_product>
    <table>enterprise_targetrule_index_related_product</table>
</index_related_product>
<index_upsell_product>
    <table>enterprise_targetrule_index_upsell_product</table>
</index_upsell_product>
<index_crosssell_product>
    <table>enterprise_targetrule_index_crosssell_product</table>
</index_crosssell_product>
```



## Adding an attribute to the `Enterise_TargetRule` module

In order to add filter product by an attribute, you need to set 'Use for Promo Rule Conditions' to 'yes' on the manage attribute screen.




