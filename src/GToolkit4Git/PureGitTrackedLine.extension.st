Extension { #name : #PureGitTrackedLine }

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtViewGraphFor: composite [
	<gtView>
	^ composite explicit
		title: 'Graph';
		priority: 20;
		stencil: [ | vertices |
			vertices := Array streamContents: [ :out | 
							self positionsInVersions doWithIndex: [ :lineNumber :rank | 
								lineNumber = 0 ifFalse: [ out nextPut: (rank * 10) @ (lineNumber * 5) ] ] ].
			vertices := vertices
					, (vertices reversed collect: [ :point | point translateBy: 0 @ 5 ]).
			BlPolygonElement new
				vertices: vertices;
				background: Color blue ]
]
