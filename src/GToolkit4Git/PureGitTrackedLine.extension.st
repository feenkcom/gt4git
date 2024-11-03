Extension { #name : #PureGitTrackedLine }

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> asKumpelGraphElement [
	| vertices maxExtent|
	maxExtent := 0.
	vertices := Array
			streamContents: [ :out | 
				self positionsInVersions
					doWithIndex: [ :lineNumber :rank | 
						lineNumber = 0
							ifFalse: [ | startPoint endPoint |
								startPoint := (rank * 12) @ (lineNumber * 5).
								endPoint := startPoint translateBy: 10 @ 0.
								maxExtent := maxExtent max: endPoint.
								out
									nextPut: startPoint;
									nextPut: endPoint ] ] ].
	vertices := vertices
			, (vertices reversed collect: [ :point | point translateBy: 0 @ 5 ]).
	^ BlElement new
		size: (maxExtent translateBy: 0 @ 5);
		geometry: (BlPolygon vertices: vertices);
		background: Color blue
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedLine >> gtViewGraphFor: composite [
	<gtView>
	^ composite explicit
		title: 'Graph';
		priority: 20;
		stencil: [ self asKumpelGraphElement asScrollableElement]
]
