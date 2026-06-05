Extension { #name : #RGMethodDefinition }

{ #category : #'*GToolkit4Git' }
RGMethodDefinition >> gtGitCommitsFor: aView [
	<gtView>
	<gtToolView>
	
	self isDefined ifFalse: [ ^aView empty].
	
	^aView forward 
		title: 'Git history';
		object: [ self method ];
		priority: 30;
		view: #gtGitCommitsFor:
]
