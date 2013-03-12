/*

This file is part of MuraComments

Copyright 2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
component persistent="false" accessors="true" output="false" extends="mura.cfobject" {

	property name='contentManager';
	property name='configBean';
	property name='debug';

	public any function init() {
		setContentManager(getBean('contentManager'));
		setConfigBean(getBean('configBean'));
		setDebug(true);
		return this;
	}


	public any function getComments(
		string siteid='default'
		, string commentid
		, string contentid
		, string parentid
		, string remoteid
		, string ip
		, string email
		, string name
		, boolean isapproved
		, string sortby='entered'
		, string sortdirection='asc'
		, boolean returnCountOnly=false
	) {
		var local = {};
		var qComments = new Query(datasource=getConfigBean().getReadOnlyDatasource());
		var rsComments = '';

		local.qryStr = '
			SELECT *
			FROM tcontentcomments
			WHERE 0=0
		';

		// siteid
		if ( StructKeyExists(arguments, 'siteid') ) {
			local.qryStr &= ' AND siteid = ( :siteid ) ';
			qComments.addParam(name='siteid', value=arguments.siteid, cfsqltype='cf_sql_varchar');
		}

		// commentid
		if ( StructKeyExists(arguments, 'commentid') ) {
			local.qryStr &= ' AND commentid = ( :commentid ) ';
			qComments.addParam(name='commentid', value=arguments.commentid, cfsqltype='cf_sql_varchar');
		}

		//contentid
		if ( StructKeyExists(arguments, 'contentid') ) {
			local.qryStr &= ' AND contentid = ( :contentid ) ';
			qComments.addParam(name='contentid', value=arguments.contentid, cfsqltype='cf_sql_varchar');
		}

		// parentid
		if ( StructKeyExists(arguments, 'parentid') ) {
			local.qryStr &= ' AND parentid = ( :parentid ) ';
			qComments.addParam(name='parentid', value=arguments.parentid, cfsqltype='cf_sql_varchar');
		}

		// remoteid
		if ( StructKeyExists(arguments, 'remoteid') ) {
			local.qryStr &= ' AND remoteid = ( :remoteid ) ';
			qComments.addParam(name='remoteid', value=arguments.remoteid, cfsqltype='cf_sql_varchar');
		}

		// ip
		if ( StructKeyExists(arguments, 'ip') ) {
			local.qryStr &= ' AND ip = ( :ip ) ';
			qComments.addParam(name='ip', value=arguments.ip, cfsqltype='cf_sql_varchar');
		}

		// email
		if ( StructKeyExists(arguments, 'email') ) {
			local.qryStr &= ' AND email = ( :email ) ';
			qComments.addParam(name='email', value=arguments.email, cfsqltype='cf_sql_varchar');
		}

		// name
		if ( StructKeyExists(arguments, 'name') ) {
			local.qryStr &= ' AND name = ( :name ) ';
			qComments.addParam(name='name', value=arguments.name, cfsqltype='cf_sql_varchar');
		}

		// isapproved
		if ( StructKeyExists(arguments, 'isapproved') ) {
			local.qryStr &= ' AND isapproved = ( :isapproved ) ';
			qComments.addParam(name='isapproved', value=arguments.isapproved, cfsqltype='cf_sql_bit');
		}

		local.qryStr &= ' ORDER BY ' & arguments.sortby & ' ' & arguments.sortdirection;

		//rsComments = qComments.setSQL(local.qryStr).execute().getResult(); // breaks in ACF9: https://github.com/stevewithington/MuraComments/issues/2 .. using workaround instead
		qComments.setSQL(local.qryStr);
		rsComments = qComments.execute().getResult();

		if ( arguments.returnCountOnly ) {
			return rsComments.recordcount;
		} else {
			return rsComments;
		}
	}


	public any function getCommentsIterator() {
		var local = {};
		local.rsComments = getComments(argumentCollection=arguments);
		local.iterator = getBean('contentCommentIterator');
		local.iterator.setQuery(local.rsComments);
		return local.iterator;
	}


	public boolean function approve(required string commentid) {
		var commentBean = getCommentBeanByCommentID(arguments.commentid);

		try {
			getContentManager().approveComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}

		try {
			commentBean.notifySubscribers();
		} catch(any e) {
			// handleError(e);
			// this will break on versions prior to 6.0.5238
			// so instead of tossing an error...just skip the notifications
		}

		return true;
	}


	public any function getCommentBeanByCommentID(required string commentid) {
		return getContentManager().getCommentBean().setCommentID(arguments.commentID).load();
	}


	public boolean function disapprove(required string commentid) {
		try {
			getContentManager().disapproveComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}
		return true;
	}


	public boolean function delete(required string commentid) {
		try {
			getContentManager().deleteComment(arguments.commentid);
		} catch(any e) {
			handleError(e);
		}
		return true;
	}


	private any function handleError(required any error) {
		if ( getDebug() ) {
			WriteDump(arguments.error);
			abort;
		} else {
			return false;
		}
	}

}