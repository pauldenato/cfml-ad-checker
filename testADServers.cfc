<cfcomponent>
	<cffunction name="login" access="remote" returntype="any">

		<cfset var adServerList=form.adServers/>
		<cfset var username = "">
		<!--- http://docs.lucee.org/reference/tags/ldap.html --->
		<!--- attribues = list of values we would like returned for the user we are querying --->
		<!--- the non secure port is 389 and does not require the secure, username and password attributes (anonymous connection to ldap server) --->
		<cfif Len(form.unamePrefix)>
			<cfset username = form.unamePrefix & form.uname>
		<cfelse>
			<cfset username = form.uname >
		</cfif>

		<cfloop list="#adServerList#" index="AD">
			<cftry>
				<cfldap
					action="query"
					name="results"
					start="#form.start#"
					scope="#form.scope#"
					server="#AD#"
					filter="(&(objectCategory=Person)(objectClass=user)(sAMAccountName=#form.uname#)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
					attributes="#form.attributes#"
					port="#form.serverPort#"
					username="#username#"
					password="#form.upassword#"
					timeout="500"
					rebind="#form.bindCall#">
				<cfcatch type="any">
					<!---ADs Fail--->
					<cfoutput>
						<h3>#AD#: failed</h3>
					  <br></cfoutput>
				</cfcatch>
			</cftry>
			<cfif isDefined('results.columnList') AND results.columnList neq "">
				<cfoutput><h3>#AD#: success</h3>
					<br></cfoutput>
			</cfif>
		</cfloop>

		<cfreturn>
	</cffunction>

</cfcomponent>
