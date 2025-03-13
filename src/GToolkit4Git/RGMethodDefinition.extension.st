Extension { #name : #RGMethodDefinition }

{ #category : #'*GToolkit4Git' }
RGMethodDefinition >> gtGitCommitsFor: aView [
	<gtView>
	
	self isDefined ifFalse: [ ^aView empty].
	
	^aView forward 
		title: 'Git history';
		object: [ self method ];
		priority: 25;
		view: #gtGitCommitsFor:
]
