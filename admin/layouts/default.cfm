<cfsilent>
<!---

This file is part of MuraComments

Copyright 2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
	<cfsavecontent variable="local.errors">
		<cfif StructKeyExists(rc, 'errors') and IsArray(rc.errors) and ArrayLen(rc.errors)>
			<div class="alert alert-error">
				<button type="button" class="close" data-dismiss="alert"><i class="icon-remove-sign"></i></button>
				<h2>Alert!</h2>
				<h3>Please note the following message<cfif ArrayLen(rc.errors) gt 1>s</cfif>:</h3>
				<ul>
					<cfloop from="1" to="#ArrayLen(rc.errors)#" index="local.e">
						<li>
							<cfif IsSimpleValue(rc.errors[local.e])>
								<cfoutput>#rc.errors[local.e]#</cfoutput>
							<cfelse>
								<cfdump var="#rc.errors[local.e]#" />
							</cfif>
						</li>
					</cfloop>
				</ul>
			</div><!--- /.alert --->
		</cfif>
	</cfsavecontent>
	<cfscript>
		param name="rc.compactDisplay" default="false";
		body = local.errors & body;
	</cfscript>
</cfsilent>
<cfsavecontent variable="local.newBody">
	<cfoutput>
		<div class="container-murafw1">

			<!--- TITLE --->
			<div class="row-fluid">
				<div class="span12">
					<h1 id="title"><i class="icon-comments"></i> #HTMLEditFormat(rc.pc.getPackage())#</h1>
				</div>
			</div>

			<!--- SITE SELECTION --->
			<div id="site-selector" class="row-fluid">
				<div class="span4">
					<cfif !ListFindNoCase(rc.listSites, rc.$.event('siteid'))>
						<p><a class="btn btn-danger" href="#rc.$.globalConfig('context')#/admin/index.cfm?muraAction=cSettings.editPlugin&amp;moduleID=#rc.pc.getModuleID()#"><i class="icon-cog"></i> Plugin Settings</a></p>
					<cfelseif rc.pc.getAssignedSites().recordcount eq 1 and rc.pc.getAssignedSites().siteid eq rc.$.siteConfig('siteid')>
						<h3><i class="icon-sitemap"></i> Site: <strong>#HTMLEditFormat(rc.$.siteConfig('site'))#</strong></h3>
					<cfelse>
						<div class="btn-group">
							<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
								<i class="icon-sitemap"></i> Site:&nbsp;&nbsp;
								<strong>#HTMLEditFormat(rc.$.siteConfig('site'))#</strong>
								&nbsp;&nbsp;<span class="caret"></span>
							</a>
							<ul class="dropdown-menu">
								<cfloop query="#rc.pc.getAssignedSites()#">
									<cfset local.tempSite = rc.$.getBean('settingsManager').getSite(siteid)>
									<cfif siteid neq rc.$.siteConfig('siteid')>
										<li>
											<a href="#buildURL(action='admin:main.default', querystring='siteid=#siteid#')#"><i class="icon-sitemap"></i>&nbsp;&nbsp;#HTMLEditFormat(local.tempSite.getSite())#</a>
										</li>
									</cfif>
								</cfloop>
							</ul>
						</div>
					</cfif>
				</div>
			</div>

			<!--- PRIMARY NAV --->
			<!--- <div class="row-fluid">
				<div class="navbar navbar-murafw1">
					<div class="navbar-inner">
						<a class="plugin-brand" href="#buildURL('admin:main')#"><i class="icon-comments"></i> #HTMLEditFormat(rc.pc.getPackage())#</a>
						<ul class="nav">
							<li class="<cfif rc.action contains 'admin:main.default'>active</cfif>">
								<a href="#buildURL('admin:main')#" ><i class="icon-home"></i> Home</a>
							</li>
							<li class="<cfif rc.action eq 'admin:main.license'>active</cfif>">
								<a href="#buildURL('admin:main.license')#"><i class="icon-legal"></i> License</a>
							</li>
							<li class="<cfif rc.action contains 'admin:settings'>active</cfif>">
								<a href="#buildURL('admin:settings')#"><i class="icon-cog"></i> Settings</a>
							</li>
						</ul>
					</div>
				</div>
			</div> --->

			<!--- MAIN CONTENT AREA --->
			<div class="row-fluid">
				<div class="span12">
					#body#
				</div>
			</div>

			<!--- FOOTER --->
			<div id="footer" class="row-fluid">
				<div class="span8">
					<ul class="nav nav-pills">
						<li>
							<a href="#buildURL('admin:main.default')#" title="Home"><i class="icon-home"></i> Home</a>
						</li>
						<li>
							<a href="#buildURL('admin:main.license')#"><i class="icon-legal"></i> License</a>
						</li>
						<li>
							<a href="#rc.$.globalConfig('context')#/admin/index.cfm?muraAction=cSettings.editPlugin&amp;moduleID=#rc.pc.getModuleID()#"><i class="icon-cog"></i> Settings</a>
						</li>
						<li>
							<a href="https://github.com/stevewithington/#HTMLEditFormat(rc.pc.getPackage())#/issues" target="_blank"><i class="icon-bullhorn"></i> Report Issue</a>
						</li>
						<li>
							<a href="https://github.com/stevewithington/#HTMLEditFormat(rc.pc.getPackage())#"><i class="icon-github"></i> View Project on Github</a>
						</li>
					</ul>
				</div>
				<div class="span4">
					<div id="copyright" class="pull-right">
						<small><a href="http://www.stephenwithington.com">&copy; #year(now())# Stephen J. Withington, Jr.</a></small>
						<a href="https://www.facebook.com/stevewithington"><i class="icon-github-sign"></i></a>
						<a href="https://twitter.com/stevewithington"><i class="icon-twitter-sign"></i></a>
						<a href="http://www.linkedin.com/in/stevewithington"><i class="icon-linkedin-sign"></i></a>
						<a href="http://pinterest.com/stevewithington/"><i class="icon-pinterest-sign"></i></a>
					</div>

				</div>
			</div><!--- /footer --->

		</div><!--- /.container-murafw1 --->
	</cfoutput>
</cfsavecontent>
<cfoutput>
	#application.pluginManager.renderAdminTemplate(
		body=local.newBody
		,pageTitle=rc.pc.getName()
		,compactDisplay=rc.compactDisplay
	)#
</cfoutput>