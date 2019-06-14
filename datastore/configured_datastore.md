# configuredatastore

Used with relational, tile cache, and spatiotemporal big data stores.

After you install ArcGIS Data Store, you can run the configuredatastore utility to create a data store and register it with a GIS Server site. You can create the following types of data stores using this command:

    Relational data store
    Tile cache data store
    Spatiotemporal big data store

You can also run the configuredatastore utility to upgrade a data store after updating the ArcGIS Data Store software on all machines in the data store.
Syntax

configuredatastore <ArcGIS Server admin URL> <ArcGIS Server administrator> <ArcGIS Server administrator password> <data directory> [--stores <relational|tileCache|spatiotemporal>] [--nosql-only true|false]

The ArcGIS Server admin URL is in the format https://gisserver.domain.com:6443. Note that even if your GIS Server site uses a web adaptor, you must provide the URL in the aforementioned format.

Provide the user name and password for a built-in (not enterprise) user who has administrator privileges in the GIS Server site.

The data directory is the location on the local machine where you want the data store files to be created.

Though it is not recommended, you can configure more than one type of data store on the same machine by specifying each store type separated by a comma (no spaces). For example, to configure both relational and tile cache data stores on the same machine with a shared data store directory, specify --stores relational,tileCache. Esri strongly recommends you run spatiotemporal big data stores on machines separate from other data stores or software.

Legacy:

In previous releases, you would set the --nosql-only option to true to create a data store only for scene layer cached tiles. This option is still present so existing scripts can continue to function. All new scripts should set the --stores option to tileCache instead.

Configure a specific type of data store

You specify the type of data store to create using the following settings with the --stores option:

    relational
    tileCache
    spatiotemporal

To configure more than one data store type on the same machine, separate the types with a comma. For example, to configure both a relational and tile cache data store on the same machine, specify --stores relational,tileCache.

Note:

Data stores configured on the same machine will compete for memory and other resources, negatively affecting performance and possibly causing the data stores to stop working. This is especially true for spatiotemporal big data stores; do not configure a spatiotemporal big data store on the same machine as another data store or other ArcGIS component.

Note that if you script the creation of multiple spatiotemporal big data store machines, one spatiotemporal big data store machine must be manually configured with the GIS Server before you can script creation of additional spatiotemporal big data store machines.
Configure data stores after updating ArcGIS Data Store installations

As part of upgrading ArcGIS Data Store, you must reconfigure the existing data store machines. After you install a new version of ArcGIS Data Store over the existing ArcGIS Data Store on every data store machine, you can log in to the primary relational or tile cache data store machine and run the configuredatastore utility to finish upgrading the data stores. When you run the utility from the primary machine, the standby relational or tile cache machine is also updated.

If your primary machine contains both a relational and tile cache data store, specify --stores relational,tileCache when you run the configuredatastore utility, and it updates the primary and standby relational and tile cache data stores.

To reconfigure updated spatiotemporal big data store machines, log on to any of the machines in the spatiotemporal big data store and run the configuredatastore utility. This updates all machines in the spatiotemporal big data store.

Note that if you have not installed the new version of ArcGIS Data Store on all machines, configuration cannot proceed.
Example

In this example, a data store for hosted feature layer data (relational data store) is created. The URL for the GIS Server site that will use the data store is https://gisserver.domain.com:6443, the site administrator user name and password are admin and Iph33l$ik, respectively, and the data directory for the data store is C:\datastore\data\.

configuredatastore https://gisserver.mydomain.com:6443 admin Iph33l$ik c:\datastore\data\ --stores relational