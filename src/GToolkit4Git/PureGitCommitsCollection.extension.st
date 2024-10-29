Extension { #name : #PureGitCommitsCollection }

{ #category : #'*GToolkit4Git' }
PureGitCommitsCollection >> gtActionReverseFor: composite [
	<gtAction>
	^ composite button
		label: 'Reverse';
		priority: 20;
		action: [ :element | element phlow spawnObject: self reversed ]
]
