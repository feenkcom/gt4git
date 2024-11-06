Extension { #name : #PureGitMethodVersions }

{ #category : #'*GToolkit4Git' }
PureGitMethodVersions >> gtDetails [
	^ super gtDetails , {
		{ 'method' . self method } 
	}
]

{ #category : #'*GToolkit4Git' }
PureGitMethodVersions >> gtViewVersionsIn: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'Versions';
		priority: 30;
		items: [ self versions ];
		column: '#' text: [ :_ :index | index ] weight: 0.125;
		column: 'commit' text: [ :each | each key timeStamp shortCommitId ] weight: 0.25;
		column: 'timestamp' text: [ :each | timestampFormat format: each key timeStamp timestamp ] weight: 0.4;
		column: 'author' text: [ :each | each key timeStamp author ];
		column: 'comment' text: [ :each | each key timeStamp comment ] weight: 2.0;
		contextItemLabel: 'Inspect diff'
			action: [ :element :item | 
				BlTaskAction
					enqueueElement: element
					action: [ element phlow spawnObject: item value ] ];
		contextItemLabel: 'Inspect commit'
			action: [ :element :item | 
				BlTaskAction
					enqueueElement: element
					action: [ element phlow spawnObject: item key timeStamp ] ];
		send: #value
]
