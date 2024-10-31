Extension { #name : #PureGitTrackedLine }

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> asKumpelGraphElement [
	| vertices |
	vertices := Array
			streamContents: [ :out | 
				self positionsInVersions
					doWithIndex: [ :lineNumber :rank | 
						lineNumber = 0
							ifFalse: [ | point |
								point := (rank * 10) @ (lineNumber * 5).
								out
									nextPut: point;
									nextPut: (point translateBy: 5 @ 0) ] ] ].
	vertices := vertices
			, (vertices reversed collect: [ :point | point translateBy: 0 @ 5 ]).
	^ BlPolygonElement new
		vertices: vertices;
		background: Color blue
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtViewGraphFor: composite [
	<gtView>
	^ composite explicit
		title: 'Graph';
		priority: 20;
		stencil: [ self asKumpelGraphElement ]
]
