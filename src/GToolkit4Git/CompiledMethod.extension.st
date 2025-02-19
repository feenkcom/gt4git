Extension { #name : #CompiledMethod }

{ #category : #'*GToolkit4Git' }
CompiledMethod >> gtGitCommitsFor: aView [
	<gtView>
	| packageName |
	^ aView columnedList
		title: 'Git history';
		priority: 15;
		items: [ packageName := self package name.
			IceRepository registry
				detect: [ :each | each includesPackageNamed: packageName ]
				ifFound: [ :repo | repo log historyOfMethod: self ]
				ifNone: [ {} ] ];
		column: 'Timestamp'
			text: [ :each | each datetime ]
			width: 170;
		column: 'Author'
			text: [ :each | each author ]
			width: 100;
		column: 'Commit'
			text: [ :each | each commit shortId ]
			width: 100;
		column: 'Comment' text: [ :each | each comment ];
		actionButtonIcon: BrGlamorousVectorIcons branching
			tooltip: 'Browse the method''s Git repository'
			action: [ :button | 
				IceRepository registry
					detect: [ :each | each includesPackageNamed: packageName ]
					ifFound: [ :repository | 
						button phlow
							spawnTool: (GtGitPhlowTool new
									repository: (GtGitRepository fromIcebergRepository: repository)) ]
					ifNone: [ {} ] ];
		actionButtonIcon: BrGlamorousVectorIcons changes 
			tooltip: 'Pure git method versions' 
			action: [ :button |
				button phlow spawnObject: (PureGitMethodVersions with: self) ]
]
