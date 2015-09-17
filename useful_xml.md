---
layout: default
title: Magento CE & EE XML
chapter: 20
meta-description: Overview of app/etc/*.xml app/etc/modules/*.xml {module}/etc/*.xml
---

# XML

## Registering a module

Create XML file in `app/etc/modules` in the format `{Namespace}_{Module}.xml` for example 'Phil_ModuleName.xml'

```xml
<config>
    <modules>
        <{Namespace}_{Module}>
            <codePool>local|community</codePool>
            <depends>...</depends>
            <active>0|1</active>
        </{Namespace}_{Module}>
    </modules>
</config>
```

## Config.xml

Create XML file in `app/code/{code_pool}/{namespace}/{module}/etc/config.xml`

### Add the module Version

```xml
<config>
    <modules>
        <{Namespace}_{Module}>
            <version>{version}</version> <!-- Something like 0.1.0 -->
        </{Namespace}_{Module}>
    </modules>
</config>
```

### Configuring Models

```xml
<config>
    <global>
        <models>    <!-- Plural -->
            <{module_identifier}>
                <class>Namespace_Module_Model</class>
            </{module_identifier}>
        </models>
    </modules>
</config>
```

Helpers and Blocks are all the same, just replace `models` with 'helpers', 'blocks'

#### Module Re-writes

```xml
<config>
    <global>
        <models>    <!-- Plural -->
            <{module_to_rewrite_identifier}>
                <rewrite>
                    <{model_name}>Namespace_Module_Model_NewClass</{model_name}>
                </rewrite>
            </{module_to_rewrite_identifier}>
        </models>
    </modules>
</config>
```

### Module Resource Models

```xml
<config>
    <global>
        <models>    <!-- Plural -->
            <{module_identifier}>
                <class>Namespace_Module_Model</class>
                <resourceModel>{resource_identifier}</resourceModel>
            </{module_identifier}>
            <{resource_identifier}>
                <class>Namespace_Module_Model_Resource</class>
                <entities>
                    <{table_alias}>
                        <table>{real_table_name}</table>
                    </{table_alias}>
                </entities>
            </{resource_identifier}>
        </models>
    </modules>
</config>
```

### Configuring a database resources

```xml
<config>
    <global>
        <resources>
            <{resource_identifier}>
                <connection>
                    <host>{host}</host>
                    <username>{username}</username>
                    <password>{password}</password>
                    <dbname>{database}</dbname>
                    <model>{model}</model>
                    <initStatements>{init commands}</initStatements>
                    <type>{adapter type}</type>
                    <active>{0|1}</active>
                </connection>
            </{resource_identifier}>
        </resources>
    </global>
</config>
```

### Configuring a setup scripts

```xml
<config>
    <global>
        <resources>
            <{resource_identifier}> <!-- {module_dir}/sql/{resource_identifier}/{scripts} -->
                <setup>
                    <module>{module}</module>
                    <class>{username}</class>
                </setup>
            </{resource_identifier}>
        </resources>
    </global>
</config>
```

### Registering an event observer

```xml
<config>
    <{area}>
        <events>    <!-- Plural -->
            <{event_identifier}>
                <observers>
                    <{unique_observer_name}>
                        <type>singleton|model</type> <!-- not needed, defaults to singleton -->
                        <class>{model_alias}/{class}</class>
                        <method>{someMethod}</method>
                    </{unique_observer_name}>
                </observers>
            </{event_identifier}>
         </events>
      </{area}>
  </config>

```

### Registering a cron

```xml
<config>
    <crontab>
        <jobs>
            <{cron_identifier}>
                <schedule>
                    <cron_expr>....</cron_expr>
                </schedule>
                <run>
                    <model>{model_identifier}/{someClass}::{someMethod}</model>
                </run>
            </{cron_identifier}>
        </jobs>
    </crontab>
  </config>

```

### Creating a new product types

```xml
<config>
    <global>
        <catalog>
            <product>
                <type>
                    <{product_type_name}>
                        <label></label>
                        <model></model>
                        <composite><composite>
                        <index_priority></index_priority>
                        <price_model></price_model>
                        ...
                    </{product_type_name}>
                </type>
            </product>
        </catalog>
    <global>
</config>
```


### Creating a new indexer

```xml
<config>
    <global>
        <index>
            <indexer>
                <{index_name}>{model}</{index_name}>
            </indexer>
        </index>
    <global>
</config>
```

### Creating a new totals model

```xml
<config>
    <global>
        <sales>
            <quote>
                <totals>
                    <{total_name}>
                        <before></before>
                        <after></after>
                        <class></class>
                    </{total_name}>
                </totals>
            </quote>
        </sales>
    <global>
</config>
```

### Adding a new router

```xml
<config>
    <default>
        <web>
            <routers>
                <{router_identifier}>
                    <area>{frontend|adminhtml}</area>
                    <class></class>
               </{router_identifier}>
           </routers>
       </web>
    <default>
</config>
```

### Using a router

```xml
<config>
    <{area}>
        <routers>
            <{router_identifier}>
                <use>{standard|admin|cms|default|custom}</use>
                <args>
                    <module>{module}</module>
                    <frontName>{front_name}</frontName>
                </args>
            </{router_identifier}>
        </routers>
    </{area}>
</config>
```

### Loading a module before a different module

```xml
<config>
	<{area}>
		<routers>
			<{module_to_override_identifier}>
				<args>
					<modules>
						<{module_identifier} before="Mage_Tag">Inchoo_Tag</module_identifier>
					</modules>
				</args>
			</{module_to_override_identifier}>
		</routers>
	</{area}>
</config>
```

### Referencing a layout file

```xml
<config>
    <{area}>
        <layout>
            <updates>
                <{layout_identifier}>
                    <file>{file_name}.xml</file>
                </{layout_identifier}>
           </updates>
       </layout>
    </{area}>
</config>
```

### Shipping Method

```xml
<config>
    <default>
        <carriers>
            <{carrier_identifier}>
                <active>{0|1}</active>
                <model>{model_identifier}/{model}</model>
                <title></title>
                <sort_order>{0|1|...}</sort_order>
                <!-- All countries = 0| Admin specified = 1 -->
                <sallowspecific>{0|1}</sallowspecific>
            </{carrier_identifier}>
        </carriers>
    </default>
</config>
```


### Config Combined
```xml
<config>
    <modules>
        <{Namespace}_{Module}>
            <version>0.1.0</codePool>
        </{Namespace}_{Module}>
    </modules>
    <global>
        <models>    <!-- Plural -->
            <{module_identifier}>
                <class>Namespace_Module_Model</class>
                <resourceModel>{resource_identifier}</resourceModel>
            </{module_identifier}>
            <{resource_identifier}>
                <class>Namespace_Module_Model_Resource</class>
                <entities>
                    <{table_alias}>
                        <table>{real_table_name}</table>
                    </{table_alias}>
                </entities>
            </{resource_identifier}>
            <{module_to_rewrite_identifier}>
                <rewrite>
                    <{model_name}>Namespace_Module_Model_NewClass</{model_name}>
                </rewrite>
            </{module_to_rewrite_identifier}>
        </models>
        <catalog>
            <product>
                <type>
                    <{product_type_name}>
                        <label></label>
                        <model></model>
                        <composite><composite>
                        <index_priority></index_priority>
                        <price_model></price_model>
                        ...
                    </{product_type_name}>
                </type>
            </product>
        </catalog>
        <index>
            <indexer>
                <{index_name}>{model}</{index_name}>
            </indexer>
        </index>
        <sales>
            <quote>
                <totals>
                    <{total_name}>
                        <before></before>
                        <after></after>
                        <class></class>
                    </{total_name}>
                </totals>
            </quote>
        </sales>
    </global>
    <{area}>
        <events>    <!-- Plural -->
            <{event_identifier}>
                <observers>
                    <{unique_observer_name}>
                        <class>{model_alias}/{class}</class>
                        <method>{someMethod}</method>
                    </{unique_observer_name}>
                </observers>
            </{event_identifier}>
        </events>
        <layout>
             <updates>
                 <{layout_identifier}>
                     <file>{file_name}.xml</file>
                 </{layout_identifier}>
            </updates>
        </layout>
        <routers>
            <contacts>
                <use>{standard|admin|cms|default|custom}</use>
                <args>
                    <module>{module}</module>
                    <frontName>{front_name}</frontName>
                </args>
            </contacts>
            <{module_to_override_identifier}>
                <args>
                    <modules>
                        <{module_identifier} before="Mage_Tag">Inchoo_Tag</module_identifier>
                    </modules>
                </args>
            </{module_to_override_identifier}>
        </routers>
    </{area}>
    <default>
        <web>
            <routers>
                 <{router_identifier}>
                    <area>{frontend|adminhtml}</area>
                    <class></class>
                </{router_identifier}>
            </routers>
        </web>
        <carriers>
            <{carrier_identifier}>
                <active>{0|1}</active>
                <model>{model_identifier}/{model}</model>
                <title></title>
                <sort_order>{0|1|...}</sort_order>
                <!-- All countries = 0| Admin specified = 1 -->
                <sallowspecific>{0|1}</sallowspecific>
            </{carrier_identifier}>
        </carriers>
    <default>
    <resources>
        <{resource_identifier}>
            <connection>
                <host>{host}</host>
                <username>{username}</username>
                <password>{password}</password>
                <dbname>{database}</dbname>
                <model>{model}</model>
                <initStatements>{init commands}</initStatements>
                <type>{adapter type}</type>
                <active>{0|1}</active>
            </connection>
            <setup>
                <module>{module}</module>
                <class>{username}</class>
            </setup>
        </{resource_identifier}>
    </resources>
</config>
```


## Adminhtml.xml

### Creating a Menu Item

```xml
<config>
    <menu>
        <{top_menu}>
            <children>
                <{sub_menu}>
                    <title>{menu_title}</title>
                    <action>{frontName/controller/action}</action>
                    <sort_order>{0|1|...}</sort_order>
                    <depends>
                        <module>{module_identifier}</module>
                        <config>{core_config_data_path}</config>
                    </depends>
                    <disabled>{0|1}</disabled>
                    <children>
                        <!-- and so on... -->
                    </children>
                </{sub_menu}>
            </children>
        <{top_menu}>
    </menu>
</config>
```

### Managing the Access Control List (ACL)

```xml
<config>
    <acl>
        <resources>
            <admin>
                <children>
                    <{sub_menu|system_menu}>
                        <title></title>
                        <sort_order></sort_order>
                        <children>
                            <!-- same again -->
                        </children>
                    </{sub_menu|system_menu}>
                </children>
            </admin>
        </resources>
    </acl>
</config>
```

## System.xml

### Adding to System > Configuration

```xml
<config>
    <tabs>
        <{tab_name} translate="label" module="{module}">
            <label>{tab_label}</label>
            <sort_order>{1|2....}</sort_order>
        </{tab_name}>
    </tabs>
    <sections>
        <{section_name} translate="label" module="{module}">
            <label>{config_label}</label>
            <tab>{tab_name}</tab>
            <sort_order>{1|2....}</sort_order>
            <show_in_default>{0|1}</show_in_default>
            <show_in_website>{0|1}</show_in_website>
            <show_in_store>{0|1}</show_in_store>
            <groups>
                <{group_name} translate="label">
                    <label>{config_label}</label>
                    <sort_order>{1|2....}</sort_order>
                    <show_in_default>{0|1}</show_in_default>
                    <show_in_website>{0|1}</show_in_website>
                    <show_in_store>{0|1}</show_in_store>
                    <fields>
                        <{field_name} translate="{elements to translate}">
                            <label>{label}</label>
                            <frontend_type>{type|Varien_Data_Form_Element_Abstract}</frontend_type>
                            <source_model>adminhtml/system_config_source_yesno</source_model>
                            <backend_model>contacts/system_config_backend_links</backend_model>
                            <sort_order>{1|2....}</sort_order>
                            <show_in_default>{0|1}</show_in_default>
                            <show_in_website>{0|1}</show_in_website>
                            <show_in_store>{0|1}</show_in_store>
                        </{field_name}>
                    </fields>
                </{group_name}>
            </groups>
        </{section_name}>
    </sections>
<config>
```

## Widget.xml

### Creating a widget

```xml
<widgets>
    <{widget_identifier} type="{block_alias}/{block_class}" translate="name description" module="{module}">
        <name>{widget_name}</name>
        <description>{widget_description}</description>
        <is_email_compatible>{0|1}</is_email_compatible>
        <parameters>
            <{param_name} translate="label">
                <visible>{0|1}</visible>
                <required>{0|1}</required>
                <label>{param_label}</label>
                <type>{label|select|test|...}</type>
                <sort_order>{1|2....}</sort_order>
                <value>{default_value}</value>
                <!-- if type is select -->
                <values>
                    <{value_identifier} translate="label">
                        <value>{value}</value>
                        <label>{value_name}</label>
                    </{value_identifier}>
                    ...
                </values>
            </param_name>
        </parameters>
    </{widget_identifier}>
</widgets>
```
