<cfsilent>
<!---

This file is part of MuraComments

Copyright 2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfoutput>
	<div class="row-fluid">
		<div class="span12">
			<cfif !ListFindNoCase(rc.listSites, rc.$.event('siteid'))>
				<h2>Site Unassigned</h2>
				<div class="alert alert-error">
					<p><strong>Ooops!</strong> You'll have to <a href="#rc.$.globalConfig('context')#/admin/index.cfm?muraAction=cSettings.editPlugin&amp;moduleID=#rc.pc.getModuleID()#">edit this plugin's settings</a> and assign this site ( <strong>#HTMLEditFormat(rc.siteName)#</strong> ) to use this plugin.</p>
				</div>
			<cfelse>
				<div class="alert alert-info">
					<p><strong>Yo Dog!</strong> How'd you end up here? <a href="#buildURL(action='admin:main.default')#">Go on home &hellip;</a></p>
				</div>
			</cfif>
		</div>
	</div>
</cfoutput>