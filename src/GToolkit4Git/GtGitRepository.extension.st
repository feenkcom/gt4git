Extension { #name : #GtGitRepository }

{ #category : #'*GToolkit4Git' }
GtGitRepository >> gtDefaultInspectorTool [
	^ GtPhlowCompositeTool new
		addTool: super gtDefaultInspectorTool;
		addTool: (GtGitPhlowTool new repository: self)
]
