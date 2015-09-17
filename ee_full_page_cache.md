---
layout: default
title: Full Page Cache
chapter: 14
meta-description: Notes on Enterprise Full Page Cache
---

# Full Page Cache

Exam proportion: ~3%.

Full page cache (FPC) literally means caching the full page HTML with a few caveats. The reason it's done is to speed up Magento. Every time a request comes in, Magento is initialised,
config is built, modules are loaded, requests are dispatched. block hierarchies are build, blocks are rendered and the output sent to the user - this is all expensive and gets even more
expensive on high-traffic Enterprise level e-commerce sites.

FPC speeds up the frontend, helps keep server load as low as possible which helps avoid downtime and also reduces infrastructure costs. The memory footprint of FPC for 1000
users is negligible when you compare it to 1000 visitors hitting the site without FPC.


## Caveats

FPC is enabled and 2 people are accessing you site concurrently. 1 had items in their basket and 1 does not, which basket will be rendered? FPC doesn't work well for this use case
so Enterprise_PageCache module caches CMS pages (including the homepage), Category View, Product View and 404 pages. All dynamic blocks bi-pass FPC and rightly so, this
provides a nice compromise between FPC and a personal user experience.

## Control Flow

1. `Mage_Core_Model_App::run()`
2. Initialises `Mage_Core_Model_Cache`
3. Sees if the cache can `Mage_Core_Model_Cache::processRequest()`
4. Which calls `Enterprise_PageCache_Model_Processor::extractContent()`
    1. Checks if the cache is enabled
    2. Check if there are any subprocessors available for the request (Cache processors)
        1. Subprocessor found, `Enterprise_PageCache_Model_Processor::_processContent()` determines cached blocks and which blocks need to be build.


## Placeholders

FPC placeholders are defined in a cache.xml file (the default placeholders are defined in Enterprse_PageCache’s config, but you can also add your own),
 and have four attributes.  The following is the process with which these placeholders interact with FPC.

To create your own placeholders create your own `Namespace/Module/etc/cache.xml` file.

A placeholder has 4 main attributes:

1. __Block__        Is the block to be cached
2. __Placeholder__  Marks the start and end of the container
3. __Container__    Implements `Enterprise_PageCache_Model_Container_Abstract`
4. __Lifetime__     Validity period for the cached block

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

Example

```xml
<config>
    <placeholders>
        <last_viewed_products>
            <block>reports/product_viewed</block>
            <placeholder>VIEWED_PRODUCTS</placeholder>
            <container>Enterprise_PageCache_Model_Container_Viewedproducts</container>
            <cache_lifetime>86400</cache_lifetime>
        </last_viewed_products>
        ....
    </placeholders>
</config>
```

When a RFC page is build in Magento each block with a placeholder is rendered with the placeholder text and cache_id appended and prepended to it so FPC knows where the
placeholder starts and finishes.

```html
<!--VIEWED_PRODUCTS_jdjfghjfhjgkhfjdhguhfudngjnfjngsafhyh8heuifhuehfjel-->
<h1>block html</h1>
<!--/VIEWED_PRODUCTS_jdjfghjfhjgkhfjdhguhfudngjnfjngsafhyh8heuifhuehfjel-->
```

Each one of these placeholders’ container classes (an instance or extension from `Enterprise_PageCache_Model_Container_Abstract`) is investigated by `Enterprise_PageCache_Model_Processor::_processContent()`
 to determine if its block can be applied without instantiating the Magento Application in a function aptly called applyWithoutApp(). This function will generally just check to
 see if that block can be loaded from the current cache. If so, the block is fetched from the cache and the cache processor moves onto the next placeholder

As mentioned above, the `container` element is an instance of `Enterprise_PageCache_Model_Container_Abstract` which is used by `Enterprise_PageCache_Model_Processor::_processContent()` to check
if the block can be applied without without the Magento app `applyWithoutApp(&$content)` which checks if the block can be loaded from cache, if it can it's added to the content with the placeholder
text removed.

```php
<?php
    /**
     * Determine and process all defined containers.
     * Direct request to pagecache/request/process action if necessary for additional processing
     *
     * @param string $content
     * @return string|false
     */
    protected function _processContent($content)
    {
        $containers = $this->_processContainers($content);
        //....
    }

    /**
     * Process Containers
     *
     * @param $content
     * @return array
     */
    protected function _processContainers(&$content)
    {
        ///...
            if (!$container->applyWithoutApp($content)) {
                $containers[] = $container;
            } else {
         //...
        return $containers;
    }

    /**
     * Generate placeholder content before application was initialized and apply to page content if possible
     *
     * @param string $content
     * @return bool
     */
    public function applyWithoutApp(&$content)
    {
        $cacheId = $this->_getCacheId();

        if ($cacheId === false) {
            $this->_applyToContent($content, '');
            return true;
        }

        $block = $this->_loadCache($cacheId);
        if ($block === false) {
            return false;
        }

        $block = Enterprise_PageCache_Helper_Url::replaceUenc($block);
        $this->_applyToContent($content, $block);
        return true;
    }
?>
```

If `applyWithoutApp` returns true for everything then the content is returned and sent back to `Mage_Core_Model_Cache::processRequest()` which renders the content without instantiating Magento.
Otherwise when `applyWithoutApp` returns false (lifetime expires / block not in cache) the

Each container whose applyWithoutApp() function returns false, which will happen whenever the placeholders’ lifetime attribute expires or the block is not found in cache, then the
cache containers will be registered in the `cached_page_containers` array in the Mage registry. The request will then be sent to `Enterprise_PageCache_ActionController::processAction()` where
each container will be created in the `applyInApp()` function - slower then full FPC but content can't be dynamic.

```php
<?php
    /**
     * Generate and apply container content in controller after application is initialized
     *
     * @param string $content
     * @return bool
     */
    public function applyInApp(&$content)
    {
        $blockContent = $this->_renderBlock();
        if ($blockContent === false) {
            return false;
        }

        if (Mage::getStoreConfig(Enterprise_PageCache_Model_Processor::XML_PATH_CACHE_DEBUG)) {
            $debugBlock = new Enterprise_PageCache_Block_Debug();
            $debugBlock->setDynamicBlockContent($blockContent);
            $debugBlock->setTags($this->_getPlaceHolderBlock()->getCacheTags());

            $debugBlock->setType($this->_placeholder->getName());
            $this->_applyToContent($content, $debugBlock->toHtml());
        } else {
            $this->_applyToContent($content, $blockContent);
        }

        $subprocessor = $this->_processor->getSubprocessor();
        if ($subprocessor) {
            $contentWithoutNestedBlocks = $subprocessor->replaceContentToPlaceholderReplacer($blockContent);
            $this->saveCache($contentWithoutNestedBlocks);
        }

        return true;
    }
?>
```