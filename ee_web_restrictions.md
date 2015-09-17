---
layout: default
title: Website Restrictions
chapter: 13
meta-description: Notes on Enterprise Website Restrictions
---

# Website Restrictions

Exam proportion: ~3%.

The Website Restrictions module in EE allows an admin to close or partially close a store. As an example you can:

1. Shut the site down completely and re-directing customers to a selected CMS page
2. Lock a store so only registered users have access. User is redirected to either:
    1. The login page
    2. Or a landing page (302 redirect) where the landing page (CMS page) can be chosed.

_Each method can set the status to 200 / 503 or 404 if it's a 404 page._

When Magento receives a request the `controller_action_predispatch` event is fired. This event is listened to by the Website Restrictions module which calls
`Enterprise_WebsiteRestriction_Model_Observer::restrictWebsite()` which determines if the action is allowed for the current session or not.


```xml
<frontend>
    <events>
        <controller_action_predispatch>
            <observers>
                <enterprise_websiterestriction>
                    <class>enterprise_websiterestriction/observer</class>
                    <method>restrictWebsite</method>
                </enterprise_websiterestriction>
            </observers>
        </controller_action_predispatch>
    </events>
</frontend>
```

### Enterprise\_WebsiteRestriction\_Model\_Observer::restrictWebsite() explained

1. The method checks that area and makes sure it's the frontend.
2. The event `websiterestriction_frontend` is dispatched. This can be listened by another module. If the listening module sets `dispatchResult->getShouldProceed()` to false the module returns.

```php
<?php
 Mage::dispatchEvent('websiterestriction_frontend', array(
     'controller' => $controller, 'result' => $dispatchResult
 ));

 if (!$dispatchResult->getShouldProceed()) {
     return;
 }
?>
```

3. If false equals `Mage::helper('enterprise_websiterestriction')->getIsRestrictionEnabled()` then the module also returns.
4. Calls a switch statement which switches over the System Config value for the modes:
    1. Website Closes
    2. Private Sales: Login or Login & Register

#### 1. Website Closed

This section of the switch statement checks the full action name. If it's not `restriction_index_stub` then it
reconfigures the request to `restriction_index_stub` and re-dispatched it. This will re-do everything that's just been done
and re-call the `controller_action_predispatch` bringing the stack through this function. This time `$controller->getFullActionName()` will
equal `restriction_index_stub` and all this code does is set the header (if it's 503). Magento will then dispatch the request which
will use the `restriction_index_stub` handle. The module specified the 'websiterestriction.xml' layout update file which has the handle
which then tells Magento to render the page with the relevant CSS, JS, Blocks and CMS blocks.

```php
<?php
// show only landing page with 503 or 200 code
 case Enterprise_WebsiteRestriction_Model_Mode::ALLOW_NONE:
     if ($controller->getFullActionName() !== 'restriction_index_stub') {
         $request->setModuleName('restriction')
             ->setControllerName('index')
             ->setActionName('stub')
             ->setDispatched(false);
         return;
     }
     $httpStatus = (int)Mage::getStoreConfig(
         Enterprise_WebsiteRestriction_Helper_Data::XML_PATH_RESTRICTION_HTTP_STATUS
     );
     if (Enterprise_WebsiteRestriction_Model_Mode::HTTP_503 === $httpStatus) {
         $response->setHeader('HTTP/1.1','503 Service Unavailable');
     }
     break;
?>
```


#### 2 Login or Login & Register

When the Website Restrictions module is set to private sales mode the first step is to check if the user is logged in or not. If they are they're either
redirected to their previous page if the session variable `getWebsiteRestrictionAfterLoginUrl(true)` is set or the code returns and the controller
stubAction is called and the customer is shown the CMS page configured in the admin.

```php
<?php
$response->setRedirect(
    Mage::getSingleton('core/session')->getWebsiteRestrictionAfterLoginUrl(true)
);
$controller->setFlag('', Mage_Core_Controller_Varien_Action::FLAG_NO_DISPATCH, true);
?>
```

If the customer is not logged in the the action being called is checked against `frontend/enterprise/websiterestriction/full_action_names` to see if the page can be accessed or not.

```php
<?php
$allowedActionNames = array_keys(Mage::getConfig()
    ->getNode(Enterprise_WebsiteRestriction_Helper_Data::XML_NODE_RESTRICTION_ALLOWED_GENERIC)
    ->asArray()
);
?>
```

The list has 2 types:

1. Generic - can always be accessed
2. Register - only if restriction is in private sales mode

Once accessible sites have been determined from the list then the action name is compared against the list and:

1. If it is allowed then the customer is redirected to that page
2. If it is not allowed then the customer is redirected to the `general/restriction/http_redirect` CMS page.
