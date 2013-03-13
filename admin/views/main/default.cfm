<cfsilent>
<!---

This file is part of MuraComments

Copyright 2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

	TODO:	
			*) possibly enable 'editing' of comments by Super Admin
			*) allow 'site' admins to edit without having to be a super admin
			*) maybe display comments grouped by content title and nested by replies
			*) flag comment as SPAM
				- allow for blacklisting/blocking IP

--->
</cfsilent>
<cfoutput>

	<!--- MESSAGING --->
	<cfif StructKeyExists(rc, 'processed') and IsBoolean(rc.processed)>
		<cfset local.class = rc.processed ? 'success' : 'error'>
		<div id="feedback" class="alert alert-#local.class#">
			<button type="button" class="close" data-dismiss="alert">&times;</button>
			<cfif rc.processed>
				<strong>Yep!</strong> That worked just fine.
			<cfelse>
				<strong>Oh snap!</strong> Something went wrong.
			</cfif>
		</div>
	</cfif>

	<!--- TAB NAV --->
	<div class="row-fluid">
		<div class="span12">
			<ul class="nav nav-tabs">
				<li<cfif !rc.isapproved> class="active"</cfif>><a href="#buildURL(action='admin:main.default', querystring='isapproved=0')#"><i class="icon-bell"></i> Pending</a></li>
				<li<cfif rc.isapproved> class="active"</cfif>><a href="#buildURL(action='admin:main.default', querystring='isapproved=1')#"><i class="icon-ok"></i> Approved</a></li>
			</ul>
		</div>
	</div>

	<!--- BODY --->
	<cfif rc.itComments.hasNext()>

		<!--- FORM --->
		<form name="frmUpdate" id="frmUpdate" method="post" action="#buildURL(action='main.bulkedit', querystring='isapproved=#rc.isapproved#&pageno=#rc.pageno#&sortby=#rc.sortby#&sortdirection=#rc.sortdirection#&siteid=#rc.siteid#')#">
			<input type="hidden" name="bulkedit" id="bulkedit" value="" />
			<table class="table table-striped table-condensed table-bordered mura-table-grid">
				<thead>
					<tr>
						<th>
							<a id="checkall" href="##" title="Select All"><i class="icon-check" title="Select All"></i></a>
						</th>
						<th>
							<a href="./?sortby=entered&amp;sortdirection=#rc.sortdirlink#&amp;isapproved=#rc.isapproved#&amp;nextn=#Val(rc.nextn)#" title="Sort By Date/Time"><i class="icon-calendar"></i> / <i class="icon-time"></i></a>
						</th>
						<th class="var-width">
							<a href="./?sortby=name&amp;sortdirection=#rc.sortdirlink#&amp;isapproved=#rc.isapproved#&amp;nextn=#Val(rc.nextn)#" title="Sort By Name"><i class="icon-user"></i></a>
						</th>
						<th>&nbsp;</th>
					</tr>
				</thead>

				<tbody>
					<!--- RECORDS --->
					<cfloop condition="rc.itComments.hasNext()">

						<cfsilent>
							<cfscript>
								local.item = rc.itComments.next();
								local.content = rc.$.getBean('content').loadBy(contentID=local.item.getContentID(),siteID=local.item.getSiteID());
							</cfscript>
						</cfsilent>

<!--- MODAL WINDOW --->
<div id="comment-#local.item.getCommentID()#" class="modal hide fade">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true" title="Close Comments"><i class="icon-comments"></i></button>
		<p>
			<strong>#HTMLEditFormat(local.item.getName())#</strong> <em>commented on:</em><br>
			<a href="#local.content.getURL(complete=1,queryString='##comment-#local.item.getCommentID()#')#" target="_blank"><i class="icon-external-link"></i> #HTMLEditFormat(local.content.getMenuTitle())#</a>
		</p>
	</div>
	<div class="modal-body">
		#application.contentRenderer.setParagraphs(HTMLEditFormat(local.item.getComments()))#
	</div>
	<div class="modal-footer">
		<div class="pull-left">
			<i class="icon-calendar"></i>&nbsp;&nbsp;#DateFormat(local.item.getEntered(), 'yyyy.mm.dd')#&nbsp;&nbsp;&nbsp;&nbsp;<i class="icon-time"></i> #TimeFormat(local.item.getEntered(), 'hh:mm:ss tt')#
		</div>
		<div class="pull-right">
			<a href="##" class="btn" data-dismiss="modal"><i class="icon-undo"></i> Cancel</a>
			<cfif rc.isapproved>
				<a href="#buildURL(action='admin:main.disapprove', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" class="btn btn-warning" onclick="return confirm('Disapprove Comment?',this.href);"><i class="icon-ban-circle"></i> Disapprove</a>
			<cfelse>
				<a href="#buildURL(action='admin:main.approve', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" class="btn btn-success" onclick="return confirm('Approve Comment?',this.href);"><i class="icon-ok"></i> Approve</a>
			</cfif>
			<a href="#buildURL(action='admin:main.delete', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" class="btn btn-danger" onclick="return confirm('Delete Comment?',this.href);"><i class="icon-trash"></i> Delete</a>
		</div>
	</div>
</div>
<!--- /@END MODAL --->

						<tr>
							<!--- BULK ACTION CHECKBOX --->
							<td>
								<input type="checkbox" name="ckUpdate" class="checkall" value="#local.item.getCommentID()#" />
							</td>

							<!--- DATE / TIME --->
							<td>
								<a href="##comment-#local.item.getCommentID()#" data-toggle="modal" title="Commented on: #HTMLEditFormat(local.content.getMenuTitle())#">
									#DateFormat(local.item.getEntered(), 'yyyy.mm.dd')# /
									#TimeFormat(local.item.getEntered(), 'hh:mm:ss tt')#
								</a>
							</td>

							<!--- USER --->
							<td class="var-width">
								<a href="##comment-#local.item.getCommentID()#" data-toggle="modal">
									#HTMLEditFormat(local.item.getName())#
								</a>

								<div class="pull-right">
									<cfif IsValid('url', local.item.getURL())>
										<a href="#HTMLEditFormat(local.item.getURL())#" title="#HTMLEditFormat(local.item.getURL())#" target="_blank"><i class="icon-link"></i></a> 
									</cfif>
									<a href="mailto:#HTMLEditFormat(local.item.getEmail())#" title="#HTMLEditFormat(local.item.getEmail())#"><i class="icon-envelope"></i></a>
									<a href="##comment-#local.item.getCommentID()#" data-toggle="modal" title="Comments"><i class="icon-comments"></i></a>
								</div>
								
							</td>

							<!--- ACTIONS --->
							<td class="actions">
								<cfif rc.isapproved>
									<a href="#buildURL(action='admin:main.disapprove', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" title="Disapprove" onclick="return confirmDialog('Disapprove Comment?',this.href);"><i class="icon-ban-circle" title="Disapprove"></i></a>
								<cfelse>
									<a href="#buildURL(action='admin:main.approve', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" title="Approve" onclick="return confirmDialog('Approve Comment?',this.href);"><i class="icon-ok" title="Approve"></i></a>
								</cfif>

								<a href="#buildURL(action='admin:main.delete', querystring='commentid=#local.item.getCommentID()#&isapproved=#rc.isapproved#&nextn=#rc.nextn#')#" title="Delete" onclick="return confirmDialog('Delete Comment?',this.href);"><i class="icon-trash" title="Delete"></i></a>
							</td>

						</tr>
					</cfloop>
					<!--- /@END RECORDS --->
				</tbody>
			</table>
		</form>
		
		<div class="row-fluid">

			<!--- BULK EDIT BUTTONS --->
			<div class="span9">
				<div class="commentform-actions">
					<cfif rc.isapproved>
						<button type="button" class="btn btn-warning" id="btnDisapproveComments">
							<i class="icon-ban-circle"></i> 
							Disapprove Selected Comments
						</button>
					<cfelse>
						<button type="button" class="btn btn-success" id="btnApproveComments">
							<i class="icon-ok"></i> 
							Approve Selected Comments
						</button>
					</cfif>
					<button type="button" class="btn btn-danger" id="btnDeleteComments">
						<i class="icon-trash"></i> 
						Delete Selected Comments
					</button>
				</div>
			</div>

			<!--- RECORDS PER PAGE --->
			<cfif rc.itComments.pageCount() gt 1>
				<div class="span3">
					<div class="btn-group pull-right">
						<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
							Comments Per Page
							<span class="caret"></span>
						</a>
						<ul class="dropdown-menu">
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=10&isapproved=#rc.isapproved#')#">10</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=25&isapproved=#rc.isapproved#')#">25</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=50&isapproved=#rc.isapproved#')#">50</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=100&isapproved=#rc.isapproved#')#">100</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=250&isapproved=#rc.isapproved#')#">250</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=500&isapproved=#rc.isapproved#')#">500</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=1000&isapproved=#rc.isapproved#')#">1000</a></li>
							<li><a href="#buildURL(action='admin:main.default', querystring='nextn=100000&isapproved=#rc.isapproved#')#">ALL</a></li>
						</ul>
					</div>
				</div>
			</cfif>
			<!--- /@END RECORDS PER PAGE --->

		</div><!--- /.row-fluid --->

		<!--- PAGINATION --->
		<cfif rc.itComments.pageCount() gt 1>
			<div id="paginationWrapper" class="row-fluid">
				<!--- <div class="span3">
					#val(rc.pageno)# of #rc.itComments.pageCount()# total pages
				</div> --->
				<div class="span12">
					<div class="pagination paginationWrapper">
						<ul>
							<!--- PREVIOUS --->
							<cfscript>
								if ( rc.pageno eq 1 ) {
									local.prevClass = 'disabled';
									local.prevURL = '##';
								} else {
									local.prevClass = '';
									local.prevURL = buildURL(action='admin:main.default', queryString='pageno=#rc.pageno-1#&nextn=#rc.nextn#&isapproved=#rc.isapproved#&sortby=#rc.sortby#&sortdirection=#rc.sortdirection#');
								}
							</cfscript>
							<li class="#local.prevClass#">
								<a href="#local.prevURL#">&laquo;</a>
							</li>
							<!--- LINKS --->
							<cfloop from="#rc.startPage#" to="#rc.endPage#" index="p">
								<li<cfif rc.pageno eq p> class="disabled"</cfif>>
									<a href="#buildURL(action='admin:main.default', queryString='pageno=#p#&nextn=#rc.nextn#&isapproved=#rc.isapproved#&sortby=#rc.sortby#&sortdirection=#rc.sortdirection#')#"<cfif val(rc.pageno) eq p> class="active"</cfif>>
										#p#
									</a>
								</li>
							</cfloop>
							<!--- NEXT --->
							<cfscript>
								if ( rc.pageno == rc.totalPages ) {
									rc.nextClass = 'disabled';
									rc.nextURL = '##';
								} else {
									rc.nextClass = '';
									rc.nextURL = buildURL(action='admin:main.default', queryString='pageno=#rc.pageno+1#&nextn=#rc.nextn#&isapproved=#rc.isapproved#&sortby=#rc.sortby#&sortdirection=#rc.sortdirection#');
								}
							</cfscript>
							<li class="#rc.nextClass#">
								<a href="#rc.nextURL#">&raquo;</a>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</cfif>

		<!--- SCRIPTS --->
		<script type="text/javascript">
			jQuery(function ($) {
				// CHECKBOXES
				$('##checkall').click(function (e) {
					e.preventDefault();
					var checkBoxes = $(':checkbox.checkall');
					checkBoxes.prop('checked', !checkBoxes.prop('checked'));
				});

				// APPROVE
				$('##btnApproveComments').click(function() {
					confirmDialog(
						'Are you sure you want to APPROVE the selected comments?'
						,function(){
							actionModal(
								function(){
									$('.commentform-actions').hide();
									$('##bulkedit').val('approve');
									$('##actionIndicator').show();
									$('##frmUpdate').submit();
								}
							);
						}
					)
				});

				// DISAPPROVE
				$('##btnDisapproveComments').click(function() {
					confirmDialog(
						'Are you sure you want to DISAPPROVE the selected comments?'
						,function(){
							actionModal(
								function(){
									$('.commentform-actions').hide();
									$('##bulkedit').val('disapprove');
									$('##actionIndicator').show();
									$('##frmUpdate').submit();
								}
							);
						}
					)
				});

				// DELETE
				$('##btnDeleteComments').click(function() {
					confirmDialog(
						'Are you sure you want to DELETE the selected comments?'
						,function(){
							actionModal(
								function(){
									$('.commentform-actions').hide();
									$('##bulkedit').val('delete');
									$('##actionIndicator').show();
									$('##frmUpdate').submit();
								}
							);
						}
					)
				});
			});
		</script>

	<cfelse>
		<div class="row-fluid">
			<div class="span12">
				<div class="alert alert-info">
					<p>No comments are <strong><cfif rc.isapproved>approved<cfelse>pending</cfif></strong> at this time &hellip; carry on.</p>
				</div>
			</div>
		</div>
	</cfif>

	<script type="text/javascript">
		jQuery(function ($) {
			$('##feedback').delay(4000).fadeOut(1500); // MESSAGING : auto-hide after 4 secs.
		});
	</script>

</cfoutput>