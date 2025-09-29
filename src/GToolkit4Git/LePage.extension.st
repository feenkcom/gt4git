Extension { #name : #LePage }

{ #category : #'*GToolkit4Git' }
LePage >> gtGitButtonFor: anAction [
	<gtAction>
	self icebergRepo ifNil: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Go to repository';
		priority: 72;
		icon: BrGlamorousVectorIcons branching;
		id: GtCoderGitButtonId;
		action: [ :aButton | 
			aButton phlow
				spawnTool: (GtGitPhlowTool new
						repository: (GtGitRepository fromIcebergRepository: self icebergRepo)) ]
]

{ #category : #'*GToolkit4Git' }
LePage >> icebergRepo [
	^ IceRepository registry
		detect: [ :repo | 
			repo location
				ifNil: [ false ]
				ifNotNil: [ repo location contains: self pageFileReference ] ]
		ifNone: [ nil ]
]
