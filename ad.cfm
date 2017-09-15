<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<title>AD User Look Up</title>
		<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet">
	</head>

	<!--- Resources --->
	<!--- https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-j-l/cfldap.html --->
	<!--- https://cfdocs.org/cfldap --->
	<!--- http://docs.lucee.org/reference/tags/ldap.html --->

	<!--- You'll need to aquire some information from your AD Person --->

	<body style="margin-top:25px; margin-bottom:25px" >
		<cfparam name="form.unamePrefix" default="">
		<!--- Can be a ',' list to send to the testADServers function. --->
		<!--- straight cvall below will only use the 1st list item. --->
		<cfparam name="form.adServers" default="">
		<cfparam name="form.uname" default="">
		<cfparam name="form.upassword" default="">
		<cfparam name="form.start" default="">
			<!--- could be 686--->
		<cfparam name="form.serverPort" default="389">
		<cfparam name="form.isSubmitted" default=false>
		<cfparam name="form.bindCall" default=true>
		<cfparam name="form.scope" default="subtree">
			<!--- will return all attributes for a user in name, value query. --->
			<!--- dn,cn,sn,givenname, etc --->
		<cfparam name="form.attributes" default="*">
		<cfparam name="form.sort" default="">

		<cfoutput>
			<div class="container">
				<div class="row">
					<div class="well">
						<h1>AD Check</h1>
						<form name="adInfo" action=""  class='form-horizontal' method="post">
							<div class="form-group">
								<div class="col-sm-2">
									<label for="unamePrefix">Prefix</label>
									<input type="text" name="unamePrefix" class="form-control" placeholder="domain\" value="#form.unamePrefix#">
								</div>
								<div class="col-sm-4">
									<label for="uname">Username</label>
									<input type="text" name="uname" class="form-control" value="#form.uname#" placeholder="Enter your Username" required="yes" message="please provide the username">
								</div>
								<div class="col-sm-6">
									<label for="password">Password</label>
									<input type="password" name="upassword" class="form-control" value="#form.upassword#" placeholder="Enter your Password" required="yes" message="please provide the password">
								</div>
							</div>
							<div class="form-group">
								<div class="col-sm-6">
									<label for="start">Start</label>
									<input type="text" name="start" class="form-control" value="#form.start#" placeholder="dc={},dc={}">
								</div>
								<div class="col-sm-6">
									<label for="adServers">AD Server</label>
									<input name="adServers" class="form-control" value="#form.adServers#" required="yes" message="please select an AD server">
								</div>
							</div>
							<div class="form-group">
								<div class="col-sm-6">
									<label for="serverPort">Port</label>
									<input name="serverPort" class="form-control" value="#form.serverPort#" required="yes" message="please select an AD server">
								</div>
								<div class="col-sm-6">
									<label for="serverPort">Bind Call</label>
									<select name="bindCall" class="form-control" >
										<option value="true" <cfif form.bindCall >select="selected"</cfif>>True</option>
										<option value="false" <cfif !form.bindCall >select="selected"</cfif>>False</option>
									</select>
								</div>
							</div>
							<div class="form-group">
								<div class="col-sm-4">
									<label for="scope">Scope</label>
									<input name="scope" class="form-control" value="#form.scope#" >
								</div>
								<div class="col-sm-4">
									<label for="attributes">Attributes</label>
									<input name="attributes" class="form-control" value="#form.attributes#" >
								</div>
								<div class="col-sm-4">
									<label for="sort">Sort</label>
									<input name="sort" class="form-control" value="#form.sort#">
								</div>
							</div>
							<hr />
							<input type="hidden" name="isSubmitted" value="true"/>
							<input type="submit" class="btn btn-primary" value="Check" name="submit">
						</form>
					</div>
				</div>

			<cfif form.isSubmitted>

				<cfif Len(form.unamePrefix)>
					<cfset username = form.unamePrefix & form.uname>
				<cfelse>
					<cfset username = form.uname >
				</cfif>

				<cftry>
					<cfldap
						action="query"
						name="results"
						start="#form.start#"
						scope="#form.scope#"
						server="#listFirst(form.adServers)#"
						filter="(&(objectCategory=Person)(objectClass=user)(sAMAccountName=#form.uname#)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
						attributes="#form.attributes#"
						sort="#form.sort#"
						port="#form.serverPort#"
						username="#username#"
						password="#form.upassword#"
						timeout="500"
						rebind="#form.bindCall#">
					<cfcatch type="any">
						<!---AD Fail--->
						<cfset results = cfcatch/>
					</cfcatch>
				</cftry>

				<div class="row">
					<div class="well">
						<!--- Simple check to see if the server(s) are up or down --->
						<cfobject component="testADServers" name="upOrDown">
						<cfset areTheyUp=upOrDown.login(form)/>
						<hr />
						<!--- HTML representation of the CFLDAP call --->
						<div class="alert alert-info">
							<h3>CFLDAP Code</h3>
							<samp>
							&lt; cfldap <br />
								&nbsp; action="query"<br />
								&nbsp; name="results"<br />
								&nbsp; start="<code><var>#form.start#</var></code>"<br />
								&nbsp; scope="<code><var>#form.scope#"</var></code><br />
								&nbsp; server="<code><var>#listFirst(form.adServers)#</var></code>"<br />
								&nbsp; filter="(&(objectCategory=Person)(objectClass=user)(sAMAccountName=<code><var>#form.uname#</var></code>)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"<br />
								&nbsp; attributes="<code><var>#form.attributes#</var></code>"<br />
								<cfif len(form.sort)>&nbsp; sort="<code><var>#form.sort#</var></code>"<br /></cfif>
								&nbsp; port="<code><var>#form.serverPort#</var></code>"<br />
								&nbsp; username="<code><var>#username#</var></code>"<br />
								&nbsp; password="<kbd><var>[removed]</var></kbd>"<br />
								&nbsp; timeout="500"<br />
								&nbsp; rebind="<code><var>#form.bindCall#</var></code>" &gt;
							</samp>
						</div>
						<hr />
						<h2>AD Lookup Completed:</h2>
						<div class="checkInfo">
							<!--- remove password from form struct --->
							<cfset toPass = form.upassword />
							<cfset removePass = StructDelete(form, 'upassword') >
							<cfdump var="#form#"/>
						</div>
						<!--- Display resutls of CFLDAP query or catch data --->
						<cfdump var="#results#">
				</div>
			</div>

		</cfif>

	</div>
</cfoutput>
</body>
</html>
