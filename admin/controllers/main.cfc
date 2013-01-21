/*

This file is part of MuraComments

Copyright 2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
component persistent="false" accessors="true" output="false" extends="controller" {

	property name='framework';
	property name='commentService';

	// *********************************  PAGES  *******************************************

	public void function default(required struct rc) {
		param name='rc.bulkedit' default='';
		param name='rc.sortby' default='entered';
		param name='rc.sortdirection' default='asc';
		param name='rc.pageno' default=1;
		param name='rc.nextn' default=25;
		param name='rc.isapproved' default=false;

		rc.rsSites = rc.pc.getAssignedSites();
		rc.listSites = ValueList(rc.rsSites.siteid);

		if ( !rc.pc.getAssignedSites().recordcount || !ListFindNoCase(rc.listSites, rc.$.event('siteid')) ) {
			getFW().redirect(action='admin:main.unassigned');
		};

		rc.siteid = rc.$.event('siteid');

		rc.sortdirlink = rc.sortdirection == 'asc' ? 'desc' : 'asc';
		rc.itComments = getCommentService().getCommentsIterator(argumentCollection=rc);

		// Pagination Setup
		if ( val(rc.nextn) < 1 ) { 
			rc.nextn = 25; 
		};
		rc.itComments.setNextN(val(rc.nextn));
		if ( val(rc.pageno) < 1 || val(rc.pageno) > rc.itComments.pageCount() ) {
			rc.pageno = 1;
		};
		rc.itComments.setPage(val(rc.pageno));

		// recordcounts
		//rc.countApproved = getCommentService().getComments(siteid=rc.siteid, isapproved=true, returnCountOnly=true);
		//rc.countDisapproved = getCommentService().getComments(siteid=rc.siteid, isapproved=false, returnCountOnly=true);;
	}


	public void function bulkedit(required struct rc) {
		var local = {};
		rc.processed = true;

		param name='rc.ckupdate' default='';
	
		if ( ListLen(rc.ckupdate) ) {
			try {
				local.arr = ListToArray(rc.ckupdate);
				for ( local.i=1; local.i <= ArrayLen(local.arr); local.i++ ) {
					switch ( rc.bulkedit ) {
						case 'approve' : getCommentService().approve(local.arr[local.i]);
							break;
						case 'disapprove' : getCommentService().disapprove(local.arr[local.i]);
							break;
						case 'delete' : getCommentService().disapprove(local.arr[local.i]);
							break;
						default : break;
					}
				}
			} catch(any e) {
				rc.processed = false;
			}
		}

		getFW().redirect(action='admin:main.default', preserve='processed,isapproved');
	}


	public void function approve(required struct rc) {
		rc.processed = false;
		if ( StructKeyExists(arguments.rc, 'commentid') ) {
			rc.processed = getCommentService().approve(arguments.rc.commentid);
		}
		getFW().redirect(action='admin:main.default', preserve='processed,isapproved');
	}


	public void function disapprove(required struct rc) {
		rc.processed = false;
		if ( StructKeyExists(arguments.rc, 'commentid') ) {
			rc.processed = getCommentService().disapprove(arguments.rc.commentid);
		}
		getFW().redirect(action='admin:main.default', preserve='processed,isapproved');
	}


	public void function delete(required struct rc) {
		rc.processed = false;
		if ( StructKeyExists(arguments.rc, 'commentid') ) {
			rc.processed = getCommentService().delete(arguments.rc.commentid);
		}
		getFW().redirect(action='admin:main.default', preserve='processed,isapproved');
	}

}