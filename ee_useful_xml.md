---
layout: default
title: Magento EE XML
chapter: 21
meta-description: Some EE module XML extensions
---

# Magento Enterprise EditionXML

### Full Page Cache placeholders

```xml
<config>
    <placeholders>
        <{placeholder_identifier}>
            <block>{block}</block>
            <placeholder>{placeholder}</placeholder>
            <container>{container_class}</container>
            <cache_lifetime>{cache_lifetime|86400}</cache_lifetime>
        </{placeholder_identifier}>
        ....
    </placeholders>
</config>
```
