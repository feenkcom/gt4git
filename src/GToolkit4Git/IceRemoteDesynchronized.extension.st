Extension { #name : #IceRemoteDesynchronized }

{ #category : #'*GToolkit4Git' }
IceRemoteDesynchronized >> gtActionPullThenPushFor: anAction inContext: aPhlowActionContext [
	<gtExceptionAction>
	<gtStackAction>
	| actionLabel |
	(aPhlowActionContext currentDebuggingSession
		hasLimitedFullActiveContextForMethod: GtGitRepository >> #push)
		ifFalse: [ ^ anAction noAction ].

	actionLabel := 'Pull changes in before pushing again'.
	^ anAction button
		label: 'Pull & Push';
		icon: BrGlamorousVectorIcons refresh;
		priority: 50;
		id: #gtPullThenPush;
		tooltip: actionLabel;
		action: [ :aButton | 
			aPhlowActionContext currentDebugger
				findLimitedFullActiveContextForMethod: GtGitRepository >> #push
				ifFound: [ :aContext | 
					aContext receiver pull.

					aPhlowActionContext currentDebugger
						restart: aContext;
						resumeAndCloseDebugger ]
				ifNone: [ self inform: 'Cannot execute action. Context not found.' ] ]
]
